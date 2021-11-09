<script>
    // import Global CSS from the svelte boilerplate
    // contains Figma color vars, spacing vars, utility classes and more
    import { GlobalCSS } from 'figma-plugin-ds-svelte';
    import { onMount } from 'svelte';
    import 'highlight.js/styles/github.css';
    import SvgName from './images.svg';

    // import xslt
    import initGroupRules from './xsl/group.xslt';
    import initBrushRules from './xsl/brush.xslt';
    import initImageRules from './xsl/image.xslt';
    //let modeNames = ["", "initGroupRules", "initBrushRules", "initImageRules"];

    // import utils
    import { transformXML } from './utils/xslt';
    import { setClipboard, selectText } from './utils/clipboard';

    // import some components
    import { Button, Label, SelectMenu, Switch, Icon, IconAdjust, IconButton, Textarea } from "figma-plugin-ds-svelte";

    // import and register library for highlighting code
    import hljs from 'highlight.js/lib/core';
    import htmlHighlight from 'highlight.js/lib/languages/xml';
    hljs.registerLanguage('xml', htmlHighlight);

    let rulesStore = [
        { 
            id: 0,
            label: "Source", 
            selected: false,
            showFilter: false,
            rules: ''
        },
        { 
            id: 1,
            label: "GeometryGroup", 
            selected: true,
            showFilter: false,
            rules: initGroupRules
        },
        {
            id: 2,
            label: "DrawingBrush", 
            selected: false,
            showFilter: true,
            rules: initBrushRules
        },
        { 
            id: 3,
            label: "DrawingImage", 
            selected: false,
            showFilter: true,
            rules: initImageRules
        }
    ];    

    let menuItems,
        newSource = '',
        nameSelected = '',
        sourceHolder = '',
        xsltRule = initGroupRules,
        resultView = '',
        disabled = true,
        resultHolder,
        isBrush = true,
        preResult,
        currentMode = {id: 0},
        pastMode = currentMode.id,
        selected = false,
        isEmpty = true,
        isError = false,
        errorMessage;

    updateMenu(0);

    // this is a reactive variable to the primary buttons disabled prop
    $: disabled = newSource == '';

    // For debugging in browser
    // import sourceCode from "./test.svg";
    // newSource = sourceCode;

    // Callback function gets executed once the component has mounted
    onMount(() => {
        document.getElementById('wrapper').classList.remove('hide');
    });

    // Handler for incoming messages from Figma
    onmessage = (event) => {
        let received = event.data.pluginMessage;
        if (received.id != '') {
            nameSelected = 'of ' + received.id;
        }
        received = received.svg.replace('xmlns="http://www.w3.org/2000/svg"', "");
        // alert(received);
        newSource = received;
    };

    /**
     * Update items in menu of rules
     */
    function updateMenu() {
        menuItems = rulesStore.map(item => ({ 
            id: item.id, 
            label: item.label,
            group: null,
            selected: item.selected
        }));
    }

    /**
     * Show formated code
     */
    function showСode() {
        if (sourceHolder.indexOf('<path ') == -1 && currentMode.id != 0) {
            isError = true;
            errorMessage = 'No supported items found';
        } else {
            isError = false;
        }

        if (selected) {
            saveChanges();
        }
        pastMode = currentMode.id;

        if (currentMode.id != 0) {
            xsltRule = rulesStore[currentMode.id].rules;
        } else {
            resultView = getHighlightedCode(sourceHolder);
            return;
        }
        
        // Get result
        preResult = transformXML(sourceHolder, xsltRule);

        if (preResult[0] != "<") {
            isError = true;
            errorMessage = preResult;
            return;
        }
        // Сlean result
        preResult = preResult.replaceAll(/ xmlns=""/g, '');
        if (!isBrush) {
            preResult = preResult.replaceAll(/>\n.+?<GeometryDrawing\.(.|\n)*?<\/GeometryDrawing>/g, '/>');
            preResult = preResult.replaceAll(/ Brush=".+?"/g, '');
        }
        // Highlight result
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
     * Toggle tweak mode
     */
    function underHood() {
        selected = !selected;
        if (!selected) {
            saveChanges();
            showСode();
        }
    }

    /**
     * Save XSLT tweaks
     */
    function saveChanges() {
        rulesStore[pastMode].rules = xsltRule;
    }

    /**
     * Reset XSLT tweaks
     */
    function reset() {
        switch (currentMode.id) {
            case 1:
                rulesStore[1].rules = initGroupRules;
                xsltRule = initGroupRules;
                break;
            case 2:
                rulesStore[2].rules = initBrushRules;
                xsltRule = initBrushRules;
                break;
            case 3:
                rulesStore[3].rules = initImageRules;
                xsltRule = initImageRules;
                break;
        }
    }

    /**
     * Displaying the source bypassing the menu
     */
    function showSource() {
        currentMode.id = 0;
        updateMenu(0);
        showСode();
    }

</script>

<div id="wrapper" class="wrapper p-xxsmall hide">

    <!-- Setup controls -->
    <Label>Code <span class="name">{nameSelected}</span></Label>
    <div class="flex row justify-content-between">
        <div class="flex-grow">
            <SelectMenu
                on:change={showСode}
                bind:menuItems
                bind:value={currentMode}
                class="mb-xxsmall"/>
        </div>
        {#if rulesStore[currentMode.id].showFilter}
            <div >
                <Switch 
                    on:change={showСode} 
                    value="value" 
                    bind:checked={isBrush}>
                    Brush
                </Switch>
            </div>
        {/if}
        {#if (currentMode.id != 0) }
        <div>
            <IconButton on:click={underHood} iconName={IconAdjust} bind:selected />
        </div>
        {/if}
    </div>

    {#if (selected && currentMode.id != 0) }
        <textarea spellcheck="false" rows="8" bind:value={xsltRule} ></textarea>
        <!-- Footer -->
        <div class="flex p-xxsmall">
            <Button on:click={reset} variant="secondary">Reset</Button>
        </div>
    {:else}

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

        {#if isError && currentMode.value != 'source' && !isEmpty }
            <!-- Error message -->
            <div class="message">
                <svg width="64px" height="64px">
                    <use xlink:href="#warning"></use>
                </svg>
                <p>
                    {@html errorMessage}
                    <br/><a href={'#'} on:click={showSource}>Show source</a>
                </p>
            </div>
        {/if}

        {#if ( !isEmpty && currentMode.value == 'source' ) || ( !isEmpty && !isError ) }
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
    {/if}


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
    .name {
        padding-left: 4px;
        text-overflow: ellipsis;
        overflow: hidden;
        white-space: nowrap;
    }

    textarea {
        font-family: var(--font-stack);
        font-size: var(--font-size-xsmall);
        font-weight: var(--font-weight-normal);
        letter-spacing: var( --font-letter-spacing-neg-xsmall);
        line-height: var(--line-height);
        position: relative;
        display: flex;
        overflow: visible;
        align-items: center;
        width: 100%;
        min-height: 62px;
        margin: 1px 0 11px 0;
        padding: 7px 4px 9px 7px;
        color: var(--black8);
        border: 1px solid var(--black1);
        border-radius: var(--border-radius-small);
        outline: none;
        background-color: var(--white);
        resize: none;
        overflow-y: auto;
    }
    textarea:focus {
        border-color: var(--blue);
    }

</style>
