/**
 * Apply an XSLT to transform XML
 * @param {String} xmlText to format
 * @param {String} xsltText to apply
 * @returns {String} formatted XML on success, xmlText on failure
 */
function transformXML(xmlText, xsltText) {
  // Bomb out if this browser does not support DOM parsing and transformation
  if (!(window.DOMParser && window.XSLTProcessor)) {
    return xmlText;
  }

  // Load the XSLT into a document
  var xsltDoc = new DOMParser().parseFromString(xsltText, "text/xml");

  // Apply that document to as a stylesheet to a transformer
  var xslt = new XSLTProcessor();
  xslt.importStylesheet(xsltDoc);

  // Load the XML into a document.
  // Trim any preceding whitespace to prevent parse failure.
  var xml = new DOMParser().parseFromString(xmlText.trim(), "text/xml");

  // Transform it
  var transformedXml = xslt.transformToDocument(xml);

  // Apply the transformed document if it was successful
  return !transformedXml ?
    xmlText :
    new XMLSerializer().serializeToString(transformedXml);
}

export { transformXML };