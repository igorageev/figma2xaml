<!-- 
  GeometryGroup

  You can tweak this code to suit your goals
  Please share your findings at 
  https://github.com/igorageev/figma2xaml/issues

-->

<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  <!-- Here is the magic: set indent to format the output -->
  <xsl:output omit-xml-declaration="yes" indent="yes"/>
  <xsl:template match="/">
    <ResourceDictionary xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation" xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"> 
      <GeometryGroup>
        <!-- Get id of resource -->
        <xsl:attribute name="x:Key">
          <xsl:value-of select="translate(svg/node()/@id, '-/. ', '__')"/>
        </xsl:attribute>
        <!-- Looping through all shapes -->
        <xsl:for-each select="//path">
          <!-- Get geometry -->
          <Geometry><xsl:value-of select="@d"/></Geometry>
        </xsl:for-each>
      </GeometryGroup>
    </ResourceDictionary>
  </xsl:template>
</xsl:stylesheet>