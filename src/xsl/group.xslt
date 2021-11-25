<!-- 
  GeometryGroup

  You can tweak this code to suit your goals
  Please share your findings at 
  https://github.com/igorageev/figma2xaml/issues

-->

<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  <xsl:output omit-xml-declaration="yes" indent="yes"/>

  <!-- RotateTransform: rotates an object around a specified point -->
  <xsl:template name="RotateIt">
    <xsl:param name="param" />
    <RotateTransform>
      <xsl:attribute name="Angle">
        <xsl:value-of select="substring-before( substring-after( $param, 'rotate(' ), ' ' )" />
      </xsl:attribute>
      <xsl:attribute name="CenterX">
        <xsl:value-of select="substring-before( substring-after( $param, ' '), ' ' )" />
      </xsl:attribute>
      <xsl:attribute name="CenterY">
        <xsl:value-of select="substring-before( substring-after( substring-after( $param, ' ' ), ' ' ), ')')" />
      </xsl:attribute>
    </RotateTransform>
  </xsl:template>

  <!-- Main container -->
  <xsl:template match="/">
    <ResourceDictionary xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation" xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"> 
      <GeometryGroup>
        <!-- Get id of resource -->
        <xsl:attribute name="x:Key">
          <xsl:value-of select="translate( svg/node()/@id, '-/. ', '__' )"/>
        </xsl:attribute>
        <xsl:apply-templates />
      </GeometryGroup>
    </ResourceDictionary>
  </xsl:template>

  <!-- Geometry: define geometric shapes -->
  <xsl:template match="path">
    <Geometry><xsl:value-of select="@d"/></Geometry>
  </xsl:template>

  <!-- EllipseGeometry: represents the geometry of a circle or ellipse -->
  <xsl:template match="ellipse|circle">
    <EllipseGeometry>
      <xsl:attribute name="Center">
        <xsl:value-of select="@cx"/>,<xsl:value-of select="@cy"/>
      </xsl:attribute>
      <xsl:if test="@r">
        <xsl:attribute name="RadiusX">
          <xsl:value-of select="@r"/>
        </xsl:attribute>
        <xsl:attribute name="RadiusY">
          <xsl:value-of select="@r"/>
        </xsl:attribute>
      </xsl:if>
      <xsl:if test="@rx">
        <xsl:attribute name="RadiusX">
          <xsl:value-of select="@rx"/>
        </xsl:attribute>
        <xsl:attribute name="RadiusY">
          <xsl:value-of select="@ry"/>
        </xsl:attribute>
      </xsl:if>
      <xsl:if test="starts-with( @transform, 'rotate(' )">
        <EllipseGeometry.Transform>
          <xsl:call-template name="RotateIt">
            <xsl:with-param name="param"><xsl:value-of select="@transform"/></xsl:with-param>
          </xsl:call-template>
        </EllipseGeometry.Transform>
      </xsl:if>
    </EllipseGeometry>
  </xsl:template>

  <!-- RectangleGeometry: describes a two-dimensional rectangle -->
  <xsl:template match="rect">
    <xsl:variable name="x">
      <xsl:choose>
        <xsl:when test="@x"><xsl:value-of select="@x"/></xsl:when>
        <xsl:otherwise>0</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="y">
      <xsl:choose>
        <xsl:when test="@y"><xsl:value-of select="@y"/></xsl:when>
        <xsl:otherwise>0</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <RectangleGeometry>
      <xsl:attribute name="Rect">
        <xsl:value-of select="$x"/>,<xsl:value-of select="$y"/>,<xsl:value-of select="@width"/>,<xsl:value-of select="@height"/>
      </xsl:attribute>
      <xsl:if test="@rx">
        <xsl:attribute name="RadiusX">
          <xsl:value-of select="@rx"/>
        </xsl:attribute>
        <xsl:attribute name="RadiusY">
          <xsl:value-of select="@rx"/>
        </xsl:attribute>
      </xsl:if>
      <xsl:if test="starts-with( @transform, 'rotate(' )">
        <RectangleGeometry.Transform>
          <xsl:call-template name="RotateIt">
            <xsl:with-param name="param"><xsl:value-of select="@transform"/></xsl:with-param>
          </xsl:call-template>
        </RectangleGeometry.Transform>
      </xsl:if>
    </RectangleGeometry>
  </xsl:template>

</xsl:stylesheet>