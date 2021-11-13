<!-- 
  Canvas

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
    <!-- Linear  -->
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
      <Canvas>
        <!-- Get id of resource -->
        <xsl:attribute name="x:Key">
          <xsl:value-of select="translate(svg/node()/@id, '-/. ', '__')"/>
        </xsl:attribute>
        <!-- Image size -->
        <xsl:attribute name="height">
          <xsl:value-of select="svg/@height"/>
        </xsl:attribute>
        <xsl:attribute name="width">
          <xsl:value-of select="svg/@width"/>
        </xsl:attribute>

        <!-- Looping through all shapes -->
        <xsl:for-each select="//path">
          <Path>
            <!-- Get geometry -->
            <xsl:attribute name="Data">
              <xsl:value-of select="@d"/>
            </xsl:attribute>
            <!-- Color -->
            <xsl:if test="@fill">
              <xsl:choose>
                <!-- Gradient -->
                <xsl:when test="starts-with(@fill, 'url(#')">
                  <Path.Fill>
                    <xsl:call-template name="GetGradient">
                      <xsl:with-param name="ref"><xsl:value-of select="substring-before(substring-after(@fill, 'url(#'), ')')"/></xsl:with-param>
                    </xsl:call-template>
                  </Path.Fill>
                </xsl:when>
                <!-- Solid -->
                <xsl:otherwise>
                  <xsl:attribute name="Fill">
                    <xsl:call-template name="GetColor">
                      <xsl:with-param name="color"><xsl:value-of select="@fill"/></xsl:with-param>
                      <xsl:with-param name="opacity"><xsl:value-of select="@fill-opacity"/></xsl:with-param>
                    </xsl:call-template>
                  </xsl:attribute>
                </xsl:otherwise>
              </xsl:choose>
            </xsl:if>

            <!-- Width of the stroke -->
            <xsl:if test="@stroke-width">
              <xsl:attribute name="StrokeThickness">
                <xsl:value-of select="@stroke-width"/>
              </xsl:attribute>
            </xsl:if>

            <!-- Stroke color-->
            <xsl:if test="@stroke">
              <xsl:choose>
                <!-- Gradient -->
                <xsl:when test="starts-with(@stroke, 'url(#')">
                  <xsl:variable name="ref" select="substring-before(substring-after(@stroke, 'url(#'), ')')" />
                  <Path.Stroke>
                    <xsl:call-template name="GetGradient">
                      <xsl:with-param name="ref"><xsl:value-of select="substring-before(substring-after(@stroke, 'url(#'), ')')"/></xsl:with-param>
                    </xsl:call-template>
                  </Path.Stroke>
                </xsl:when>
                <!-- Solid -->
                <xsl:otherwise>
                  <xsl:attribute name="Stroke">
                    <xsl:call-template name="GetColor">
                      <xsl:with-param name="color"><xsl:value-of select="@stroke"/></xsl:with-param>
                      <xsl:with-param name="opacity"><xsl:value-of select="@stroke-opacity"/></xsl:with-param>
                    </xsl:call-template>
                  </xsl:attribute>
                </xsl:otherwise>
              </xsl:choose>
            </xsl:if>

          </Path>
        </xsl:for-each>

      </Canvas>
    </ResourceDictionary>
  </xsl:template>
</xsl:stylesheet>