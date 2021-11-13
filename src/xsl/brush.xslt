<!-- 
  DrawingBrush

  You can tweak this code to suit your goals
  Please share your findings at 
  https://github.com/igorageev/figma2xaml/issues

-->

<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  <!-- Here is the magic: set indent to format the output -->
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
    <!-- Get transparency -->
    <xsl:if test="$opacity">
      <xsl:value-of select="substring($hexTransparency, $opacity*200+1, 2)"/>
    </xsl:if>
    <!-- Get color -->
    <xsl:choose>
      <xsl:when test="starts-with($color, '#')">
        <xsl:value-of select="substring($color, 2)"/>
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
        substring($text, 1, 1),
        'abcdefghijklmnopqrstuvwxyz',
        'ABCDEFGHIJKLMNOPQRSTUVWXYZ'
      ),
      substring($text,2,string-length($text)-1)
    )"/>
  </xsl:template>
  
  <!-- Draw gradient -->
  <xsl:template name="GetGradient">
    <xsl:param name="ref" />
    <!-- Linear -->
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
    <!-- Radial -->
    <xsl:if test="//radialGradient[@id=$ref]">
      <RadialGradientBrush>
        <!-- TODO: uncomment after adding support for <RadialGradientBrush.RelativeTransform> -->
        <!-- <xsl:attribute name="MappingMode">
          <xsl:choose>
            <xsl:when test="//radialGradient[@id=$ref]/@gradientUnits = 'userSpaceOnUse' ">Absolute</xsl:when>
            <xsl:otherwise>RelativeToBoundingBox</xsl:otherwise>
          </xsl:choose>
        </xsl:attribute> -->
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

  <!-- Main template -->
  <xsl:template match="/">
    <ResourceDictionary xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation" xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"> 
      <DrawingBrush>
        <!-- Get id of resource -->
        <xsl:attribute name="x:Key">
          <xsl:value-of select="translate(svg/node()/@id, '-/. ', '__')"/>
        </xsl:attribute>
        <xsl:attribute name="Stretch">None</xsl:attribute>
        <DrawingBrush.Drawing>
          <DrawingGroup>
            <DrawingGroup.Children>
              <!-- Looping through all shapes -->
              <xsl:for-each select="//path">
                <GeometryDrawing>
                  <!-- Get geometry -->
                  <xsl:attribute name="Geometry">
                    <xsl:value-of select="@d"/>
                  </xsl:attribute>
                  <!-- Color -->
                  <xsl:if test="@fill">
                    <xsl:choose>
                      <!-- Gradient -->
                      <xsl:when test="starts-with(@fill, 'url(#')">
                        <GeometryDrawing.Brush>
                          <xsl:call-template name="GetGradient">
                            <xsl:with-param name="ref"><xsl:value-of select="substring-before(substring-after(@fill, 'url(#'), ')')"/></xsl:with-param>
                          </xsl:call-template>
                        </GeometryDrawing.Brush>
                      </xsl:when>
                      <!-- Solid -->
                      <xsl:otherwise>
                        <xsl:attribute name="Brush">
                          <xsl:call-template name="GetColor">
                            <xsl:with-param name="color"><xsl:value-of select="@fill"/></xsl:with-param>
                            <xsl:with-param name="opacity"><xsl:value-of select="@fill-opacity"/></xsl:with-param>
                          </xsl:call-template>
                        </xsl:attribute>
                      </xsl:otherwise>
                    </xsl:choose>
                  </xsl:if>
                  <!-- Pen -->
                  <xsl:if test="@stroke">
                    <GeometryDrawing.Pen>
                      <Pen>
                        <!-- Width of the stroke -->
                        <xsl:if test="@stroke-width">
                          <xsl:attribute name="Thickness">
                            <xsl:value-of select="@stroke-width"/>
                          </xsl:attribute>
                        </xsl:if>
                        <!-- Type of shape to use at the ends of a stroke -->
                        <xsl:if test="@stroke-linecap">
                          <xsl:attribute name="StartLineCap">
                            <xsl:call-template name="CapitalizeFirst">
                              <xsl:with-param name="text"><xsl:value-of select="@stroke-linecap"/></xsl:with-param>
                            </xsl:call-template>
                          </xsl:attribute>
                          <xsl:attribute name="EndLineCap">
                            <xsl:call-template name="CapitalizeFirst">
                              <xsl:with-param name="text"><xsl:value-of select="@stroke-linecap"/></xsl:with-param>
                            </xsl:call-template>
                          </xsl:attribute>
                        </xsl:if>
                        <!-- Type of join that is used at the vertices of a Shape -->
                        <xsl:if test="@stroke-linejoin">
                          <xsl:attribute name="LineJoin">
                            <xsl:call-template name="CapitalizeFirst">
                              <xsl:with-param name="text"><xsl:value-of select="@stroke-linejoin"/></xsl:with-param>
                            </xsl:call-template>
                          </xsl:attribute>
                        </xsl:if>
                        <!-- Color -->
                        <xsl:choose>
                          <!-- Gradient -->
                          <xsl:when test="starts-with(@stroke, 'url(#')">
                            <xsl:variable name="ref" select="substring-before(substring-after(@stroke, 'url(#'), ')')" />
                            <Pen.Brush>
                              <xsl:call-template name="GetGradient">
                                <xsl:with-param name="ref"><xsl:value-of select="substring-before(substring-after(@stroke, 'url(#'), ')')"/></xsl:with-param>
                              </xsl:call-template>
                            </Pen.Brush>
                          </xsl:when>
                          <!-- Solid -->
                          <xsl:otherwise>
                            <xsl:attribute name="Brush">
                              <xsl:call-template name="GetColor">
                                <xsl:with-param name="color"><xsl:value-of select="@stroke"/></xsl:with-param>
                                <xsl:with-param name="opacity"><xsl:value-of select="@stroke-opacity"/></xsl:with-param>
                              </xsl:call-template>
                            </xsl:attribute>
                          </xsl:otherwise>
                        </xsl:choose>
                      </Pen>
                    </GeometryDrawing.Pen>
                  </xsl:if>
                </GeometryDrawing>
              </xsl:for-each>
            </DrawingGroup.Children>
          </DrawingGroup>
        </DrawingBrush.Drawing>
      </DrawingBrush>
    </ResourceDictionary>
  </xsl:template>
</xsl:stylesheet>