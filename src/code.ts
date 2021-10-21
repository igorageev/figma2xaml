// This shows the HTML page in "ui.html".
figma.showUI(__html__, { width: 320, height: 280 });

const allowedTypes = ['FRAME', 'GROUP', 'COMPONENT', 'INSTANCE'];

figma.on('selectionchange', () => {
    let selection = figma.currentPage.selection;
    let node = selection[0];
    if (selection.length == 1 && allowedTypes.includes(node.type) && node.children.length > 0) {
        
        console.log('Type of selected node: ' + node.type);
        node.exportAsync({
            format: 'SVG',
            svgOutlineText: false,
            svgIdAttribute: true
        }).then(
            res => {
                figma.ui.postMessage({
                    svg: String.fromCharCode.apply(null, res),
                    id: node.name
                })
            }
        )
        
    } else {
        figma.ui.postMessage({svg: '', id: ''});
    }
});
