/**
 * Copy code to clipboard
 * @param {Element} node with copied text
 */
function setClipboard(node) {
    if (navigator.clipboard) {
        navigator.clipboard.writeText(node.textContent);
    } else {
        selectText(node);
        document.execCommand("copy");
    }
}

/**
 * Select text of Element
 * @param {Element} node to select
 * @returns {Boolean} true on success, false on failure
 */
function selectText(node) {
    if (document.body.createTextRange) {
        const range = document.body.createTextRange();
        range.moveToElementText(node);
        range.select();
        return true;
    } else if (window.getSelection) {
        const selection = window.getSelection();
        const range = document.createRange();
        range.selectNodeContents(node);
        selection.removeAllRanges();
        selection.addRange(range);
        return true;
    } else {
        console.warn("Could not select text in node: Unsupported browser.");
        return false;
    }
}

export { setClipboard, selectText };