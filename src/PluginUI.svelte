<script>
    // import Global CSS from the svelte boilerplate
    // contains Figma color vars, spacing vars, utility classes and more
    import { GlobalCSS } from 'figma-plugin-ds-svelte';
    import { onMount } from 'svelte';
    import 'highlight.js/styles/github.css';
    import SvgName from './images.svg';

    // import xslt
    import transform2group from './xsl/group.xml';
    import transform2brush from './xsl/brush.xml';
    import transform2image from './xsl/image.xml';

    // import utils
    import { transformXML } from './utils/xslt';
    import { setClipboard, selectText } from './utils/clipboard';

    // import some components
    import { Button, Label, SelectMenu, Switch } from "figma-plugin-ds-svelte";

    // import and register library for highlighting code
    import hljs from 'highlight.js/lib/core';
    import htmlHighlight from 'highlight.js/lib/languages/xml';
    hljs.registerLanguage('xml', htmlHighlight);

    // menu items, this is an array of objects to populate to our select menus
    let menuItems = [
        { value: "group", label: "GeometryGroup", group: null, selected: true },
        { value: "brush", label: "DrawingBrush", group: null, selected: false },
        { value: "image", label: "DrawingImage", group: null, selected: false },
        { value: "source", label: "Source", group: null, selected: false },
    ];

    var newSource = '',
        sourceHolder = '',
        xsltRule = new XMLSerializer().serializeToString(transform2group),
        textContent = '',
        resultView = '',
        disabled = true,
        resultHolder,
        isBrush = true,
        preResult,
        displayedСode = {value: 'group'},
        isEmpty = true,
        isError = false;

    // this is a reactive variable to the primary buttons disabled prop
    $: disabled = newSource == '';

    // For debugging in browser
    // import sourceCode from "./test.xml";
    // newSource = new XMLSerializer().serializeToString(sourceCode);

    // Callback function gets executed once the component has mounted
    onMount(() => {
        document.getElementById('wrapper').classList.remove('hide');
    });

    // Handler for incoming messages from Figma
    onmessage = (event) => {
        let received = event.data.pluginMessage;
        received = received.replace('xmlns="http://www.w3.org/2000/svg"', "");
        newSource = received;
    };

    /**
     * Show formated code
     */
    function showСode() {
        if (sourceHolder.indexOf('<path ') == -1 && displayedСode.value != 'source') {
            isError = true;
        } else {
            isError = false;
        }

        switch (displayedСode.value) {
            case "group":
                xsltRule = new XMLSerializer().serializeToString(transform2group);
                break;
            case "brush":
                xsltRule = new XMLSerializer().serializeToString(transform2brush);
                break;
            case "image":
                xsltRule = new XMLSerializer().serializeToString(transform2image);
                break;
            default:
                resultView = getHighlightedCode(sourceHolder);
                return;
        }

        preResult = transformXML(sourceHolder, xsltRule);

        if (!isBrush) {
            preResult = preResult.replaceAll(/ Brush=".+?"/g, '');
        }
        preResult = getHighlightedCode(preResult);
        resultView = preResult;
    }

    /**
     * Update and show new code
     */
    function getCode() {
        if (newSource != '') {
            sourceHolder = newSource;
            isEmpty = false;
        } else {
            isEmpty = true;
            return;
        }
        showСode();
    }

    /**
     * Highlight code
     * @param {String} code plain text
     * @returns {String} formatted html text
     */
     function getHighlightedCode(code) {
        return hljs.highlight(code, { language: "xml" }).value;
    }

    /**
     * Copy code to clipboard
     */
    function copy() {
        resultHolder = document.getElementById('code');
        if (resultHolder) {
            setClipboard(resultHolder);
        }
    }

    /**
     * Alternate show code
     */
    function showSource() {
        displayedСode.value = 'source';
        menuItems = [
            { value: "group", label: "GeometryGroup", group: null, selected: false },
            { value: "brush", label: "DrawingBrush", group: null, selected: false },
            { value: "image", label: "DrawingImage", group: null, selected: false },
            { value: "source", label: "Source", group: null, selected: true },
        ];
        showСode();
    }

</script>

<div id="wrapper" class="wrapper p-xxsmall hide">

    <!-- Setup controls -->
    <Label>Code</Label>
    <div class="flex row justify-content-between">
        <div class="flex-grow">
            <SelectMenu
                on:change={showСode}
                bind:menuItems
                bind:value={displayedСode}
                class="mb-xxsmall"/>
        </div>
        {#if displayedСode.value != 'group' && displayedСode.value != 'source'}
            <div >
                <Switch 
                    on:change={showСode} 
                    value="value" 
                    bind:checked={isBrush}>
                    Brush
                </Switch>
            </div>
        {/if}
    </div>

    {#if isEmpty }
        <!-- Wellcome message -->
        <div class="message">
            <svg width="64px" height="64px">
                <use xlink:href="#wellcome"></use>
            </svg>
            <p>
                Select only one layer with<br/>
                frame, group, component or instance
            </p>
        </div>
    {/if}

    {#if isError && displayedСode.value != 'source' && !isEmpty }
        <!-- Error message -->
        <div class="message">
            <svg width="64px" height="64px">
                <use xlink:href="#warning"></use>
            </svg>
            <p>
                No supported items found<br/>
                <a href={'#'} on:click={showSource}>Show source</a>
            </p>
        </div>
    {/if}

    {#if ( !isEmpty && displayedСode.value == 'source' ) || ( !isEmpty && !isError ) }
        <!-- Show result here -->
        <div class="view">
            <pre><code id="code" class="language-html">{@html resultView}</code></pre>
        </div>
    {/if}

    <!-- Footer -->
    <div class="flex p-xxsmall">
        <Button on:click={getCode} bind:disabled>Get Code</Button>
        <Button on:click={copy} variant="secondary" class="ml-xxsmall btn">Copy</Button>
    </div>
</div>
{@html SvgName}

<style>
    .view {
        width: 100%;
        padding: 0 8px;
    }
    pre {
        width: 100%;
        height: 126px;
        padding: 0;
        margin: 0 0 15px;
        overflow: scroll;
        line-height: 18px;
        -ms-overflow-style: none; /* Hide scrollbar for IE and Edge */
        scrollbar-width: none; /* Hide scrollbar for Firefox */
    }
    pre::-webkit-scrollbar, /* Hide scrollbar for Chrome, Safari and Opera */
    .hide {
        display: none;
    }

    .message {
        height: 126px;
        margin: 0 0 15px;
        font-size: 11px;
        line-height: 16px;
        color: gray;
        text-align: center;
    }
    .message p {
        margin: 4px;
    }

</style>
