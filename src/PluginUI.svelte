<script>
    // import Global CSS from the svelte boilerplate
    // contains Figma color vars, spacing vars, utility classes and more
    import { GlobalCSS } from 'figma-plugin-ds-svelte';
    import { onMount } from 'svelte';
    import 'highlight.js/styles/github.css';
    import SvgName from './img/collection.svg';

    // import xslt
    import initGroupRules from './xsl/group.xslt';
    import initBrushRules from './xsl/brush.xslt';
    import initImageRules from './xsl/image.xslt';
    import initCanvasRules from './xsl/canvas.xslt';

    // import utils
    import { transformXML } from './utils/xslt';
    import { setClipboard, selectText } from './utils/clipboard';

    // import some components
    import { Button, Label, SelectMenu, Switch, Icon, IconAdjust, IconListDetailed, IconButton, Textarea } from "figma-plugin-ds-svelte";

    // import and register library for highlighting code
    import hljs from 'highlight.js/lib/core';
    import htmlHighlight from 'highlight.js/lib/languages/xml';
    hljs.registerLanguage('xml', htmlHighlight);

    let rulesStore = [
        { 
            id: 0,
            label: 'Source', 
            showFilter: false,
            rules: ''
        },
        { 
            id: 1,
            label: 'GeometryGroup', 
            showFilter: false,
            rules: initGroupRules
        },
        {
            id: 2,
            label: 'DrawingBrush', 
            showFilter: true,
            rules: initBrushRules
        },
        { 
            id: 3,
            label: 'DrawingImage', 
            showFilter: true,
            rules: initImageRules
        },
        { 
            id: 4,
            label: 'Canvas', 
            showFilter: true,
            rules: initCanvasRules
        }
    ];

    let filterStore = [
        { 
            label: 'Brush', 
            show: true,
            replacements: [
                {
                    rules: [2,3],
                    find: />\n.+?<GeometryDrawing\.(.|\n)*?<\/GeometryDrawing>/g,
                    replace: '/>'
                },
                {
                    rules: [2,3],
                    find: / Brush=".+?"/g,
                    replace: ''
                },
                {
                    rules: [4],
                    find: / Fill=".+?"/g,
                    replace: ''
                },
                {
                    rules: [4],
                    find: / Stroke.*?=".+?"/g,
                    replace: ''
                },
                {
                    rules: [4],
                    find: />\n.+?<Path\.(.|\n)*?<\/Path>/g,
                    replace: '/>'
                }
            ]
        },
        { 
            label: 'ResourceDictionary', 
            show: true,
            replacements: [
                {
                    rules: [1,2,3,4],
                    find: /\n\s\s/g,
                    replace: '\n'
                },
                {
                    rules: [1,2,3,4],
                    find: /<\/?ResourceDictionary.*>\n?/g,
                    replace: ''
                }
            ]
        },
        { 
            label: 'Key', 
            show: true,
            replacements: [
                {
                    rules: [1,2,3,4],
                    find: / x:Key.*?=".+?"/g,
                    replace: ''
                }
            ]
        }
    ]

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
        currentMode = {id: 1},
        pastMode = currentMode.id,
        tweakMode = false,
        filterMode = false,
        isEmpty = true,
        error = 0, // 0: no error; 1: svg problem; 2: xslt problem
        errorMessage;

    updateMenu(0);

    // this is a reactive variable to the primary buttons disabled prop
    $: disabled = newSource == '';

    // For debugging in browser
    // import sourceCode from "./img/test.svg";
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
        received = received.svg.replace('xmlns="http://www.w3.org/2000/svg"', '');
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
            selected: currentMode.id == item.id ? true : false
        }));
    }

    /**
     * Show formated code
     */
    function showСode() {
        if (sourceHolder.indexOf('<path ') == -1 && currentMode.id != 0) {
            error = 1;
            errorMessage = 'No supported items found';
        } else {
            error = 0;
        }

        if (tweakMode) {
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

        // Validate result
        if (preResult[0] != '<') {
            error = 2;
            errorMessage = preResult;
            return;
        }
        // Сlean result
        preResult = preResult.replaceAll(/ xmlns=""/g, '');

        // Apply approved filters
        for (const item of filterStore) {
            if(!item.show) {
                for (const action of item.replacements) {
                    if (action.rules.includes(currentMode.id)) {
                        preResult = preResult.replaceAll(action.find, action.replace);
                    }
                }
            }
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
        return hljs.highlight(code, { language: 'xml' }).value;
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
        tweakMode = !tweakMode;
        filterMode = false;
        if (!tweakMode) {
            saveChanges();
            showСode();
        }
    }

    /**
     * Toggle filter mode
     */
    function showFilter() {
        filterMode = !filterMode;
        if (tweakMode) {
            tweakMode = false;
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
            case 4:
                rulesStore[4].rules = initCanvasRules;
                xsltRule = initCanvasRules;
                break;
        }
    }

    /**
     * Displaying the source bypassing the menu
     */
    function showSource() {
        switch (error) {
            case 1:
                rulesStore[currentMode.id].selected = false;
                // rulesStore[0].selected = true;
                currentMode.id = 0;
                updateMenu();
                showСode();
                break;
            case 2:
                tweakMode = true;
                break;
        }
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
        {#if (currentMode.id != 0) }
            <div class="flex row">
                <IconButton on:click={showFilter} iconName={IconListDetailed} bind:selected={filterMode} />
                <IconButton on:click={underHood} iconName={IconAdjust} bind:selected={tweakMode} />
            </div>
        {/if}
    </div>

    {#if (tweakMode && currentMode.id != 0) }
        <textarea spellcheck="false" rows="8" bind:value={xsltRule} ></textarea>
        <!-- Footer -->
        <div class="flex row p-xxsmall justify-content-between">
            <Button on:click={reset} variant="secondary">Reset</Button>
            <Label>Changes will also be lost <br>after closing the plugin</Label>
        </div>
    {:else if (filterMode && currentMode.id != 0)}
        <div >
            <Switch 
                on:change={showСode} 
                value="value" 
                bind:checked={filterStore[0].show}>
                {filterStore[0].label}
            </Switch>
        </div>
        <div >
            <Switch 
                on:change={showСode} 
                value="value" 
                bind:checked={filterStore[1].show}>
                {filterStore[1].label}
            </Switch>
        </div>
        <div >
            <Switch 
                on:change={showСode} 
                value="value" 
                bind:checked={filterStore[2].show}>
                {filterStore[2].label}
            </Switch>
        </div>
        <Label>Disabled items will not appear in xaml</Label>
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

        {#if error && currentMode.id != 0 && !isEmpty }
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

        {#if ( !isEmpty && currentMode.id == 0 ) || ( !isEmpty && !error ) }
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
