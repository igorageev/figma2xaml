<!-- 
  DrawingImage

  You can tweak this code to suit your goals
  Please share your findings at 
  https://github.com/igorageev/figma2xaml/issues

-->

<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  <xsl:output omit-xml-declaration="yes" indent="yes"/>
  
  <!-- Hexadecimal color codes for transparency -->
  <xsl:variable name="hexTransparency" select="'000305080A0D0F1214171A1C1F212426292B2E303336383B3D404245474A4D4F525457595C5E616366696B6E707375787A7D808285878A8C8F919496999C9EA1A3A6A8ABADB0B3B5B8BABDBFC2C4C7C9CCCFD1D4D6D9DBDEE0E3E6E8EBEDF0F2F5F7FAFCFF'"/>
  
  <!-- Color Names -->
  <xsl:template name="NameToHex">
    <xsl:param name="color" />
    <xsl:choose>
      <xsl:when test="$color = 'black'">000000</xsl:when>
      <xsl:when test="$color = 'white'">FFFFFF</xsl:when>
      <xsl:when test="$color = 'red'">FF0000</xsl:when>
      <xsl:when test="$color = 'lime'">00FF00</xsl:when>
      <xsl:when test="$color = 'blue'">0000FF</xsl:when>
      <xsl:otherwise>FFFFFF</xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <!-- Color with transparency -->
  <xsl:template name="GetColor">
    <xsl:param name="color" />
    <xsl:param name="opacity" />
    <xsl:text>#</xsl:text>
    <xsl:if test="$opacity">
      <xsl:value-of select="substring( $hexTransparency, $opacity*200+1, 2 )"/>
    </xsl:if>
    <xsl:choose>
      <xsl:when test="starts-with( $color, '#' )">
        <xsl:value-of select="substring( $color, 2 )"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="NameToHex">
          <xsl:with-param name="color"><xsl:value-of select="$color"/></xsl:with-param>
        </xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <!-- Capitalize first letter -->
  <xsl:template name="CapitalizeFirst">
    <xsl:param name="text" />
    <xsl:value-of select=
    "concat(
      translate(
        substring( $text, 1, 1 ),
        'abcdefghijklmnopqrstuvwxyz',
        'ABCDEFGHIJKLMNOPQRSTUVWXYZ'
      ),
      substring($text,2,string-length($text)-1)
    )"/>
  </xsl:template>

  <!-- Draw gradient -->
  <xsl:template name="GetGradient">
    <xsl:param name="ref" />
    <xsl:if test="//linearGradient[@id=$ref]">
      <LinearGradientBrush>
        <xsl:attribute name="MappingMode">
          <xsl:choose>
            <xsl:when test="//linearGradient[@id=$ref]/@gradientUnits = 'userSpaceOnUse' ">Absolute</xsl:when>
            <xsl:otherwise>RelativeToBoundingBox</xsl:otherwise>
          </xsl:choose>
        </xsl:attribute>
        <xsl:attribute name="StartPoint">
          <xsl:value-of select="//linearGradient[@id=$ref]/@x1"/>
          <xsl:text>,</xsl:text>
          <xsl:value-of select="//linearGradient[@id=$ref]/@y1"/>
        </xsl:attribute>
        <xsl:attribute name="EndPoint">
          <xsl:value-of select="//linearGradient[@id=$ref]/@x2"/>
          <xsl:text>,</xsl:text>
          <xsl:value-of select="//linearGradient[@id=$ref]/@y2"/>
        </xsl:attribute>
        <xsl:for-each select="//linearGradient[@id=$ref]/stop">
          <GradientStop>
            <xsl:attribute name="Color">
              <xsl:call-template name="GetColor">
                <xsl:with-param name="color"><xsl:value-of select="@stop-color"/></xsl:with-param>
                <xsl:with-param name="opacity"><xsl:value-of select="@stop-opacity"/></xsl:with-param>
              </xsl:call-template>
            </xsl:attribute>
            <xsl:if test="@offset">
              <xsl:attribute name="Offset">
                <xsl:value-of select="@offset" />
              </xsl:attribute>
            </xsl:if>
          </GradientStop>
        </xsl:for-each>
      </LinearGradientBrush>
    </xsl:if>
    <xsl:if test="//radialGradient[@id=$ref]">
      <RadialGradientBrush>
        <xsl:attribute name="MappingMode">
          <xsl:choose>
            <xsl:when test="//radialGradient[@id=$ref]/@gradientUnits = 'userSpaceOnUse' ">Absolute</xsl:when>
            <xsl:otherwise>RelativeToBoundingBox</xsl:otherwise>
          </xsl:choose>
        </xsl:attribute>
        <xsl:variable name="scale" select="substring-before( substring-after( //radialGradient[@id=$ref]/@gradientTransform, 'scale(' ), ')' )" />
        <xsl:variable name="rotate" select="substring-before( substring-after( //radialGradient[@id=$ref]/@gradientTransform, 'rotate(' ), ')' )" />
        <xsl:variable name="translate" select="substring-before( substring-after( //radialGradient[@id=$ref]/@gradientTransform, 'translate(' ), ')' )" />
        <xsl:if test="$rotate or $translate or $scale">
          <xsl:attribute name="Center">
            <xsl:text>0,0</xsl:text>
          </xsl:attribute>
          <xsl:attribute name="GradientOrigin">
            <xsl:text>0,0</xsl:text>
          </xsl:attribute>
        </xsl:if>
        <xsl:if test="$scale">
          <xsl:choose>
            <xsl:when test="contains($scale, ' ')">
              <xsl:attribute name="RadiusX">
                <xsl:value-of select="substring-before( $scale, ' ' )" />
              </xsl:attribute>
              <xsl:attribute name="RadiusY">
                <xsl:value-of select="substring-after( $scale, ' ' )" />
              </xsl:attribute>
            </xsl:when>
            <xsl:otherwise>
              <xsl:attribute name="RadiusX">
                <xsl:value-of select="$scale" />
              </xsl:attribute>
              <xsl:attribute name="RadiusY">
                <xsl:value-of select="$scale" />
              </xsl:attribute>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:if>
        <xsl:if test="$rotate or $translate">
          <RadialGradientBrush.Transform>
            <TransformGroup>
              <xsl:if test="$rotate">
                <RotateTransform>
                  <xsl:attribute name="Angle">
                    <xsl:value-of select="$rotate" />
                  </xsl:attribute>
                </RotateTransform>
              </xsl:if>
              <xsl:if test="$translate">
                <TranslateTransform>
                  <xsl:attribute name="X">
                    <xsl:value-of select="substring-before( $translate, ' ' )" />
                  </xsl:attribute>
                  <xsl:attribute name="Y">
                    <xsl:value-of select="substring-after( $translate, ' ' )" />
                  </xsl:attribute>
                </TranslateTransform>
              </xsl:if>
            </TransformGroup>
          </RadialGradientBrush.Transform>
        </xsl:if>
        <xsl:for-each select="//radialGradient[@id=$ref]/stop">
          <GradientStop>
            <xsl:attribute name="Color">
              <xsl:call-template name="GetColor">
                <xsl:with-param name="color"><xsl:value-of select="@stop-color"/></xsl:with-param>
                <xsl:with-param name="opacity"><xsl:value-of select="@stop-opacity"/></xsl:with-param>
              </xsl:call-template>
            </xsl:attribute>
            <xsl:if test="@offset">
              <xsl:attribute name="Offset">
                <xsl:value-of select="@offset" />
              </xsl:attribute>
            </xsl:if>
          </GradientStop>
        </xsl:for-each>
      </RadialGradientBrush>
    </xsl:if>
  </xsl:template>

  <!-- Brush as attribute -->
  <xsl:template name="GetAttributeBrush">
    <xsl:if test="./@fill and not( starts-with( ./@fill, 'url(#' ) )">
      <xsl:attribute name="Brush">
        <xsl:call-template name="GetColor">
          <xsl:with-param name="color"><xsl:value-of select="./@fill"/></xsl:with-param>
          <xsl:with-param name="opacity"><xsl:value-of select="./@fill-opacity"/></xsl:with-param>
        </xsl:call-template>
      </xsl:attribute>
    </xsl:if>
  </xsl:template>

  <!-- Brush as node -->
  <xsl:template name="GetNodeBrush">
    <xsl:variable name="container">
      <xsl:choose>
        <xsl:when test="local-name() = 'circle'">EllipseGeometry.Brush</xsl:when>
        <xsl:when test="local-name() = 'ellipse'">EllipseGeometry.Brush</xsl:when>
        <xsl:when test="local-name() = 'rect'">RectangleGeometry.Brush</xsl:when>
        <xsl:otherwise>GeometryDrawing.Brush</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:if test="starts-with(./@fill, 'url(#')">
      <xsl:element name="{$container}">
        <xsl:call-template name="GetGradient">
          <xsl:with-param name="ref"><xsl:value-of select="substring-before( substring-after( ./@fill, 'url(#' ), ')' )"/></xsl:with-param>
        </xsl:call-template>
      </xsl:element>
    </xsl:if>
  </xsl:template>

  <!-- Pen: outline of the shape -->
  <xsl:template name="GetStroke">
    <xsl:variable name="container">
      <xsl:choose>
        <xsl:when test="local-name() = 'circle'">EllipseGeometry.Pen</xsl:when>
        <xsl:when test="local-name() = 'ellipse'">EllipseGeometry.Pen</xsl:when>
        <xsl:when test="local-name() = 'rect'">RectangleGeometry.Pen</xsl:when>
        <xsl:otherwise>GeometryDrawing.Pen</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:if test="./@stroke">
      <xsl:element name="{$container}">
        <Pen>
          <xsl:if test="./@stroke-width">
            <xsl:attribute name="Thickness">
              <xsl:value-of select="./@stroke-width"/>
            </xsl:attribute>
          </xsl:if>
          <xsl:if test="./@stroke-linecap">
            <xsl:attribute name="StartLineCap">
              <xsl:call-template name="CapitalizeFirst">
                <xsl:with-param name="text"><xsl:value-of select="./@stroke-linecap"/></xsl:with-param>
              </xsl:call-template>
            </xsl:attribute>
            <xsl:attribute name="EndLineCap">
              <xsl:call-template name="CapitalizeFirst">
                <xsl:with-param name="text"><xsl:value-of select="./@stroke-linecap"/></xsl:with-param>
              </xsl:call-template>
            </xsl:attribute>
          </xsl:if>
          <xsl:if test="./@stroke-linejoin">
            <xsl:attribute name="LineJoin">
              <xsl:call-template name="CapitalizeFirst">
                <xsl:with-param name="text"><xsl:value-of select="./@stroke-linejoin"/></xsl:with-param>
              </xsl:call-template>
            </xsl:attribute>
          </xsl:if>
          <xsl:choose>
            <xsl:when test="starts-with( ./@stroke, 'url(#' )">
              <Pen.Brush>
                <xsl:call-template name="GetGradient">
                  <xsl:with-param name="ref"><xsl:value-of select="substring-before( substring-after( ./@stroke, 'url(#' ), ')' )"/></xsl:with-param>
                </xsl:call-template>
              </Pen.Brush>
            </xsl:when>
            <xsl:otherwise>
              <xsl:attribute name="Brush">
                <xsl:call-template name="GetColor">
                  <xsl:with-param name="color"><xsl:value-of select="./@stroke"/></xsl:with-param>
                  <xsl:with-param name="opacity"><xsl:value-of select="./@stroke-opacity"/></xsl:with-param>
                </xsl:call-template>
              </xsl:attribute>
            </xsl:otherwise>
          </xsl:choose>
        </Pen>
      </xsl:element>
    </xsl:if>
  </xsl:template>

  <!-- RotateTransform: rotates an object around a specified point -->
  <xsl:template name="RotateIt">
    <xsl:param name="param" />
    <RotateTransform>
      <xsl:attribute name="Angle">
        <xsl:value-of select="substring-before( substring-after( $param, 'rotate('), ' ' )" />
      </xsl:attribute>
      <xsl:attribute name="CenterX">
        <xsl:value-of select="substring-before( substring-after( $param, ' '), ' ' )" />
      </xsl:attribute>
      <xsl:attribute name="CenterY">
        <xsl:value-of select="substring-before( substring-after( substring-after( $param, ' '), ' '), ')' )" />
      </xsl:attribute>
    </RotateTransform>
  </xsl:template>

  <!-- Main container -->
  <xsl:template match="/">
    <ResourceDictionary xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation" xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"> 
      <DrawingImage>
        <!-- Get id of resource -->
        <xsl:attribute name="x:Key">
          <xsl:value-of select="translate( svg/node()/@id, '-/. ', '__' )"/>
        </xsl:attribute>
        <xsl:attribute name="Stretch">None</xsl:attribute>
        <DrawingImage.Drawing>
          <DrawingGroup>
            <xsl:attribute name="ClipGeometry">M0,0 V<xsl:value-of select="svg/@height"/> H<xsl:value-of select="svg/@width"/> V0 H0 Z</xsl:attribute>
            <xsl:apply-templates />
          </DrawingGroup>
        </DrawingImage.Drawing>
      </DrawingImage>
    </ResourceDictionary>
  </xsl:template>

  <!-- GeometryDrawing: draws a series of connected lines and curves -->
  <xsl:template match="path">
    <GeometryDrawing>
      <xsl:call-template name="GetAttributeBrush" />
      <xsl:attribute name="Geometry">
        <xsl:value-of select="@d"/>
      </xsl:attribute>
      <xsl:call-template name="GetNodeBrush" />
      <xsl:call-template name="GetStroke" />
    </GeometryDrawing>
  </xsl:template>

  <!-- EllipseGeometry: represents the geometry of a circle or ellipse -->
  <xsl:template match="ellipse|circle">
    <EllipseGeometry>
      <xsl:call-template name="GetAttributeBrush" />
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
      <xsl:call-template name="GetNodeBrush" />
      <xsl:call-template name="GetStroke" />
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
      <xsl:call-template name="GetAttributeBrush" />
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
      <xsl:call-template name="GetNodeBrush" />
      <xsl:call-template name="GetStroke" />
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