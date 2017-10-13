<!DOCTYPE qgis PUBLIC 'http://mrcc.com/qgis.dtd' 'SYSTEM'>
<qgis version="2.18.12" simplifyAlgorithm="0" minimumScale="0" maximumScale="1e+08" simplifyDrawingHints="1" minLabelScale="0" maxLabelScale="1e+08" simplifyDrawingTol="1" readOnly="0" simplifyMaxScale="1" hasScaleBasedVisibilityFlag="0" simplifyLocal="1" scaleBasedLabelVisibilityFlag="0">
  <edittypes>
    <edittype widgetv2type="TextEdit" name="l2_group_number">
      <widgetv2config IsMultiline="0" fieldEditable="1" constraint="" UseHtml="0" labelOnTop="0" constraintDescription="" notNull="0"/>
    </edittype>
    <edittype widgetv2type="TextEdit" name="linear_name_full">
      <widgetv2config IsMultiline="0" fieldEditable="1" constraint="" UseHtml="0" labelOnTop="0" constraintDescription="" notNull="0"/>
    </edittype>
    <edittype widgetv2type="TextEdit" name="fcode_desc">
      <widgetv2config IsMultiline="0" fieldEditable="1" constraint="" UseHtml="0" labelOnTop="0" constraintDescription="" notNull="0"/>
    </edittype>
    <edittype widgetv2type="TextEdit" name="dir_bin">
      <widgetv2config IsMultiline="0" fieldEditable="1" constraint="" UseHtml="0" labelOnTop="0" constraintDescription="" notNull="0"/>
    </edittype>
    <edittype widgetv2type="TextEdit" name="year">
      <widgetv2config IsMultiline="0" fieldEditable="1" constraint="" UseHtml="0" labelOnTop="0" constraintDescription="" notNull="0"/>
    </edittype>
    <edittype widgetv2type="TextEdit" name="avg_vol">
      <widgetv2config IsMultiline="0" fieldEditable="1" constraint="" UseHtml="0" labelOnTop="0" constraintDescription="" notNull="0"/>
    </edittype>
  </edittypes>
  <renderer-v2 forceraster="0" symbollevels="0" type="singleSymbol" enableorderby="0">
    <symbols>
      <symbol alpha="0" clip_to_extent="1" type="line" name="0">
        <layer pass="0" class="SimpleLine" locked="0">
          <prop k="capstyle" v="square"/>
          <prop k="customdash" v="5;2"/>
          <prop k="customdash_map_unit_scale" v="0,0,0,0,0,0"/>
          <prop k="customdash_unit" v="MM"/>
          <prop k="draw_inside_polygon" v="0"/>
          <prop k="joinstyle" v="bevel"/>
          <prop k="line_color" v="125,125,125,255"/>
          <prop k="line_style" v="solid"/>
          <prop k="line_width" v="0.26"/>
          <prop k="line_width_unit" v="MM"/>
          <prop k="offset" v="0"/>
          <prop k="offset_map_unit_scale" v="0,0,0,0,0,0"/>
          <prop k="offset_unit" v="MM"/>
          <prop k="use_custom_dash" v="0"/>
          <prop k="width_map_unit_scale" v="0,0,0,0,0,0"/>
        </layer>
        <layer pass="0" class="MarkerLine" locked="0">
          <prop k="interval" v="3"/>
          <prop k="interval_map_unit_scale" v="0,0,0,0,0,0"/>
          <prop k="interval_unit" v="MM"/>
          <prop k="offset" v="0"/>
          <prop k="offset_along_line" v="0"/>
          <prop k="offset_along_line_map_unit_scale" v="0,0,0,0,0,0"/>
          <prop k="offset_along_line_unit" v="MM"/>
          <prop k="offset_map_unit_scale" v="0,0,0,0,0,0"/>
          <prop k="offset_unit" v="MM"/>
          <prop k="placement" v="centralpoint"/>
          <prop k="rotate" v="1"/>
          <symbol alpha="0" clip_to_extent="1" type="marker" name="@0@1">
            <layer pass="0" class="SimpleMarker" locked="0">
              <prop k="angle" v="0"/>
              <prop k="color" v="255,127,0,255"/>
              <prop k="horizontal_anchor_point" v="1"/>
              <prop k="joinstyle" v="bevel"/>
              <prop k="name" v="filled_arrowhead"/>
              <prop k="offset" v="0,0"/>
              <prop k="offset_map_unit_scale" v="0,0,0,0,0,0"/>
              <prop k="offset_unit" v="MM"/>
              <prop k="outline_color" v="0,0,0,255"/>
              <prop k="outline_style" v="solid"/>
              <prop k="outline_width" v="0"/>
              <prop k="outline_width_map_unit_scale" v="0,0,0,0,0,0"/>
              <prop k="outline_width_unit" v="MM"/>
              <prop k="scale_method" v="area"/>
              <prop k="size" v="4"/>
              <prop k="size_map_unit_scale" v="0,0,0,0,0,0"/>
              <prop k="size_unit" v="MM"/>
              <prop k="vertical_anchor_point" v="1"/>
            </layer>
          </symbol>
        </layer>
      </symbol>
    </symbols>
    <rotation/>
    <sizescale scalemethod="diameter"/>
  </renderer-v2>
  <labeling type="rule-based">
    <rules key="{a917a6b2-b97c-4fdd-8796-1c600ab7e263}">
      <rule scalemaxdenom="50000" description="Main map, EB NB" filter="(dir_bin = 1) AND NOT(&quot;fcode_desc&quot; = 'Expressway' AND &quot;linear_name_full&quot; LIKE '%Gardiner%')&#xd;&#xa;AND NOT(within($geometry, geometry(get_feature('void_box','id',1))))&#xd;&#xa;AND NOT(&quot;linear_name_full&quot; LIKE '%Dovercourt%' OR &quot;linear_name_full&quot; LIKE '%Cosburn%' OR &quot;linear_name_full&quot; LIKE '%Millwick%')&#xd;&#xa;AND NOT(&quot;l2_group_number&quot; IN (34739,38805,708, 1258))" key="{cd5767f3-bb8d-4afd-96a6-8c1b9aa6e94f}" scalemindenom="35000">
        <settings>
          <text-style fontItalic="0" fontFamily="MS Shell Dlg 2" fontLetterSpacing="0" fontUnderline="0" fontWeight="50" fontStrikeout="0" textTransp="0" previewBkgrdColor="#ffffff" fontCapitals="0" textColor="0,0,0,255" fontSizeInMapUnits="0" isExpression="1" blendMode="0" fontSizeMapUnitScale="0,0,0,0,0,0" fontSize="10" fieldName="format_number(round(avg_vol,-1) ,0)" namedStyle="Normal" fontWordSpacing="0" useSubstitutions="0">
            <substitutions/>
          </text-style>
          <text-format placeDirectionSymbol="0" multilineAlign="0" rightDirectionSymbol=">" multilineHeight="1" plussign="0" addDirectionSymbol="0" leftDirectionSymbol="&lt;" formatNumbers="0" decimals="3" wrapChar="" reverseDirectionSymbol="0"/>
          <text-buffer bufferSize="1" bufferSizeMapUnitScale="0,0,0,0,0,0" bufferColor="255,255,255,255" bufferDraw="0" bufferBlendMode="0" bufferTransp="0" bufferSizeInMapUnits="0" bufferNoFill="0" bufferJoinStyle="64"/>
          <background shapeSizeUnits="1" shapeType="0" shapeSVGFile="" shapeOffsetX="0" shapeOffsetY="0" shapeBlendMode="0" shapeFillColor="255,255,255,255" shapeTransparency="0" shapeSizeMapUnitScale="0,0,0,0,0,0" shapeSizeType="0" shapeJoinStyle="64" shapeDraw="0" shapeBorderWidthUnits="1" shapeSizeX="0" shapeSizeY="0" shapeOffsetMapUnitScale="0,0,0,0,0,0" shapeRadiiX="0" shapeRadiiY="0" shapeOffsetUnits="1" shapeRotation="0" shapeBorderWidth="0" shapeBorderColor="128,128,128,255" shapeRotationType="0" shapeBorderWidthMapUnitScale="0,0,0,0,0,0" shapeRadiiMapUnitScale="0,0,0,0,0,0" shapeRadiiUnits="1"/>
          <shadow shadowOffsetMapUnitScale="0,0,0,0,0,0" shadowOffsetGlobal="1" shadowRadiusUnits="1" shadowTransparency="30" shadowColor="0,0,0,255" shadowUnder="0" shadowScale="100" shadowOffsetDist="1" shadowDraw="0" shadowOffsetAngle="135" shadowRadius="1.5" shadowRadiusMapUnitScale="0,0,0,0,0,0" shadowBlendMode="6" shadowRadiusAlphaOnly="0" shadowOffsetUnits="1"/>
          <placement repeatDistanceUnit="1" placement="2" maxCurvedCharAngleIn="20" repeatDistance="0" distInMapUnits="0" labelOffsetInMapUnits="1" xOffset="0" distMapUnitScale="0,0,0,0,0,0" predefinedPositionOrder="TR,TL,BR,BL,R,L,TSR,BSR" preserveRotation="1" repeatDistanceMapUnitScale="0,0,0,0,0,0" centroidWhole="0" priority="5" yOffset="0" offsetType="0" placementFlags="4" centroidInside="0" dist="0" angleOffset="0" maxCurvedCharAngleOut="-20" fitInPolygonOnly="0" quadOffset="4" labelOffsetMapUnitScale="0,0,0,0,0,0"/>
          <rendering fontMinPixelSize="3" scaleMax="100000" fontMaxPixelSize="10000" scaleMin="150000" upsidedownLabels="0" limitNumLabels="0" obstacle="1" obstacleFactor="2" scaleVisibility="0" fontLimitPixelSize="0" mergeLines="1" obstacleType="0" labelPerPart="0" zIndex="0" maxNumLabels="2000" displayAll="0" minFeatureSize="10"/>
          <data-defined/>
        </settings>
      </rule>
      <rule scalemaxdenom="50000" description="Main Map, WB SB" filter="(dir_bin = -1) AND NOT(&quot;fcode_desc&quot; = 'Expressway' AND &quot;linear_name_full&quot; LIKE '%Gardiner%')&#xd;&#xa;AND NOT(within($geometry, geometry(get_feature('void_box','id',1))))&#xd;&#xa;AND NOT(&quot;linear_name_full&quot; LIKE '%Dovercourt%' OR &quot;linear_name_full&quot; LIKE '%Cosburn%' OR &quot;linear_name_full&quot; LIKE '%Millwick%')&#xd;&#xa;AND NOT(&quot;l2_group_number&quot; IN (26806,26881,462,545,1528))" key="{7436d3e5-a834-4345-9026-e3d24c4ef437}" scalemindenom="35000">
        <settings>
          <text-style fontItalic="0" fontFamily="MS Shell Dlg 2" fontLetterSpacing="0" fontUnderline="0" fontWeight="50" fontStrikeout="0" textTransp="0" previewBkgrdColor="#ffffff" fontCapitals="0" textColor="0,0,0,255" fontSizeInMapUnits="0" isExpression="1" blendMode="0" fontSizeMapUnitScale="0,0,0,0,0,0" fontSize="10" fieldName="format_number(round(avg_vol,-1) ,0)" namedStyle="Normal" fontWordSpacing="0" useSubstitutions="0">
            <substitutions/>
          </text-style>
          <text-format placeDirectionSymbol="0" multilineAlign="0" rightDirectionSymbol=">" multilineHeight="1" plussign="0" addDirectionSymbol="0" leftDirectionSymbol="&lt;" formatNumbers="0" decimals="3" wrapChar="" reverseDirectionSymbol="0"/>
          <text-buffer bufferSize="1" bufferSizeMapUnitScale="0,0,0,0,0,0" bufferColor="255,255,255,255" bufferDraw="0" bufferBlendMode="0" bufferTransp="0" bufferSizeInMapUnits="0" bufferNoFill="0" bufferJoinStyle="64"/>
          <background shapeSizeUnits="1" shapeType="0" shapeSVGFile="" shapeOffsetX="0" shapeOffsetY="0" shapeBlendMode="0" shapeFillColor="255,255,255,255" shapeTransparency="0" shapeSizeMapUnitScale="0,0,0,0,0,0" shapeSizeType="0" shapeJoinStyle="64" shapeDraw="0" shapeBorderWidthUnits="1" shapeSizeX="0" shapeSizeY="0" shapeOffsetMapUnitScale="0,0,0,0,0,0" shapeRadiiX="0" shapeRadiiY="0" shapeOffsetUnits="1" shapeRotation="0" shapeBorderWidth="0" shapeBorderColor="128,128,128,255" shapeRotationType="0" shapeBorderWidthMapUnitScale="0,0,0,0,0,0" shapeRadiiMapUnitScale="0,0,0,0,0,0" shapeRadiiUnits="1"/>
          <shadow shadowOffsetMapUnitScale="0,0,0,0,0,0" shadowOffsetGlobal="1" shadowRadiusUnits="1" shadowTransparency="30" shadowColor="0,0,0,255" shadowUnder="0" shadowScale="100" shadowOffsetDist="1" shadowDraw="0" shadowOffsetAngle="135" shadowRadius="1.5" shadowRadiusMapUnitScale="0,0,0,0,0,0" shadowBlendMode="6" shadowRadiusAlphaOnly="0" shadowOffsetUnits="1"/>
          <placement repeatDistanceUnit="1" placement="2" maxCurvedCharAngleIn="20" repeatDistance="0" distInMapUnits="0" labelOffsetInMapUnits="1" xOffset="0" distMapUnitScale="0,0,0,0,0,0" predefinedPositionOrder="TR,TL,BR,BL,R,L,TSR,BSR" preserveRotation="1" repeatDistanceMapUnitScale="0,0,0,0,0,0" centroidWhole="0" priority="5" yOffset="0" offsetType="0" placementFlags="4" centroidInside="0" dist="0" angleOffset="0" maxCurvedCharAngleOut="-20" fitInPolygonOnly="0" quadOffset="4" labelOffsetMapUnitScale="0,0,0,0,0,0"/>
          <rendering fontMinPixelSize="3" scaleMax="100000" fontMaxPixelSize="10000" scaleMin="150000" upsidedownLabels="0" limitNumLabels="0" obstacle="1" obstacleFactor="0" scaleVisibility="0" fontLimitPixelSize="0" mergeLines="1" obstacleType="0" labelPerPart="0" zIndex="0" maxNumLabels="2000" displayAll="0" minFeatureSize="10"/>
          <data-defined/>
        </settings>
      </rule>
      <rule scalemaxdenom="35000" description="FGG EB" filter="(dir_bin = 1) AND (fcode_desc = 'Expressway')&#xd;&#xa;AND NOT( &quot;linear_name_full&quot; LIKE  'Don Valley Parkway%')" key="{a103cc3e-e064-4bd5-b1da-a3b2a24736a6}" scalemindenom="29999">
        <settings>
          <text-style fontItalic="0" fontFamily="MS Shell Dlg 2" fontLetterSpacing="0" fontUnderline="0" fontWeight="50" fontStrikeout="0" textTransp="0" previewBkgrdColor="#ffffff" fontCapitals="0" textColor="0,0,0,255" fontSizeInMapUnits="0" isExpression="1" blendMode="0" fontSizeMapUnitScale="0,0,0,0,0,0" fontSize="12" fieldName="format_number(round(avg_vol,-1) ,0)" namedStyle="Normal" fontWordSpacing="0" useSubstitutions="0">
            <substitutions/>
          </text-style>
          <text-format placeDirectionSymbol="0" multilineAlign="0" rightDirectionSymbol=">" multilineHeight="1" plussign="0" addDirectionSymbol="0" leftDirectionSymbol="&lt;" formatNumbers="0" decimals="3" wrapChar="" reverseDirectionSymbol="0"/>
          <text-buffer bufferSize="1" bufferSizeMapUnitScale="0,0,0,0,0,0" bufferColor="255,255,255,255" bufferDraw="0" bufferBlendMode="0" bufferTransp="0" bufferSizeInMapUnits="0" bufferNoFill="0" bufferJoinStyle="64"/>
          <background shapeSizeUnits="1" shapeType="0" shapeSVGFile="" shapeOffsetX="0" shapeOffsetY="0" shapeBlendMode="0" shapeFillColor="255,255,255,255" shapeTransparency="0" shapeSizeMapUnitScale="0,0,0,0,0,0" shapeSizeType="0" shapeJoinStyle="64" shapeDraw="0" shapeBorderWidthUnits="1" shapeSizeX="0" shapeSizeY="0" shapeOffsetMapUnitScale="0,0,0,0,0,0" shapeRadiiX="0" shapeRadiiY="0" shapeOffsetUnits="1" shapeRotation="0" shapeBorderWidth="0" shapeBorderColor="128,128,128,255" shapeRotationType="0" shapeBorderWidthMapUnitScale="0,0,0,0,0,0" shapeRadiiMapUnitScale="0,0,0,0,0,0" shapeRadiiUnits="1"/>
          <shadow shadowOffsetMapUnitScale="0,0,0,0,0,0" shadowOffsetGlobal="1" shadowRadiusUnits="1" shadowTransparency="30" shadowColor="0,0,0,255" shadowUnder="0" shadowScale="100" shadowOffsetDist="1" shadowDraw="0" shadowOffsetAngle="135" shadowRadius="1.5" shadowRadiusMapUnitScale="0,0,0,0,0,0" shadowBlendMode="6" shadowRadiusAlphaOnly="0" shadowOffsetUnits="1"/>
          <placement repeatDistanceUnit="1" placement="2" maxCurvedCharAngleIn="20" repeatDistance="0" distInMapUnits="0" labelOffsetInMapUnits="1" xOffset="0" distMapUnitScale="0,0,0,0,0,0" predefinedPositionOrder="TR,TL,BR,BL,R,L,TSR,BSR" preserveRotation="1" repeatDistanceMapUnitScale="0,0,0,0,0,0" centroidWhole="0" priority="10" yOffset="0" offsetType="0" placementFlags="4" centroidInside="0" dist="2" angleOffset="0" maxCurvedCharAngleOut="-20" fitInPolygonOnly="0" quadOffset="4" labelOffsetMapUnitScale="0,0,0,0,0,0"/>
          <rendering fontMinPixelSize="3" scaleMax="30000" fontMaxPixelSize="10000" scaleMin="60000" upsidedownLabels="0" limitNumLabels="0" obstacle="1" obstacleFactor="2" scaleVisibility="0" fontLimitPixelSize="0" mergeLines="1" obstacleType="0" labelPerPart="0" zIndex="0" maxNumLabels="2000" displayAll="0" minFeatureSize="0"/>
          <data-defined/>
        </settings>
      </rule>
      <rule scalemaxdenom="35000" description="FGG WB" filter="(dir_bin = -1) AND (fcode_desc = 'Expressway')&#xd;&#xa;AND NOT( &quot;linear_name_full&quot; LIKE  'Don Valley Parkway%')&#xd;&#xa;AND NOT(l2_group_number = 40917)" key="{6cbbde1a-b03a-43cd-9878-d2d794b27c1f}" scalemindenom="29999">
        <settings>
          <text-style fontItalic="0" fontFamily="MS Shell Dlg 2" fontLetterSpacing="0" fontUnderline="0" fontWeight="50" fontStrikeout="0" textTransp="0" previewBkgrdColor="#ffffff" fontCapitals="0" textColor="0,0,0,255" fontSizeInMapUnits="0" isExpression="1" blendMode="0" fontSizeMapUnitScale="0,0,0,0,0,0" fontSize="12" fieldName="format_number(round(avg_vol,-1) ,0)" namedStyle="Normal" fontWordSpacing="0" useSubstitutions="0">
            <substitutions/>
          </text-style>
          <text-format placeDirectionSymbol="0" multilineAlign="0" rightDirectionSymbol=">" multilineHeight="1" plussign="0" addDirectionSymbol="0" leftDirectionSymbol="&lt;" formatNumbers="0" decimals="3" wrapChar="" reverseDirectionSymbol="0"/>
          <text-buffer bufferSize="1" bufferSizeMapUnitScale="0,0,0,0,0,0" bufferColor="255,255,255,255" bufferDraw="0" bufferBlendMode="0" bufferTransp="0" bufferSizeInMapUnits="0" bufferNoFill="0" bufferJoinStyle="64"/>
          <background shapeSizeUnits="1" shapeType="0" shapeSVGFile="" shapeOffsetX="0" shapeOffsetY="0" shapeBlendMode="0" shapeFillColor="255,255,255,255" shapeTransparency="0" shapeSizeMapUnitScale="0,0,0,0,0,0" shapeSizeType="0" shapeJoinStyle="64" shapeDraw="0" shapeBorderWidthUnits="1" shapeSizeX="0" shapeSizeY="0" shapeOffsetMapUnitScale="0,0,0,0,0,0" shapeRadiiX="0" shapeRadiiY="0" shapeOffsetUnits="1" shapeRotation="0" shapeBorderWidth="0" shapeBorderColor="128,128,128,255" shapeRotationType="0" shapeBorderWidthMapUnitScale="0,0,0,0,0,0" shapeRadiiMapUnitScale="0,0,0,0,0,0" shapeRadiiUnits="1"/>
          <shadow shadowOffsetMapUnitScale="0,0,0,0,0,0" shadowOffsetGlobal="1" shadowRadiusUnits="1" shadowTransparency="30" shadowColor="0,0,0,255" shadowUnder="0" shadowScale="100" shadowOffsetDist="1" shadowDraw="0" shadowOffsetAngle="135" shadowRadius="1.5" shadowRadiusMapUnitScale="0,0,0,0,0,0" shadowBlendMode="6" shadowRadiusAlphaOnly="0" shadowOffsetUnits="1"/>
          <placement repeatDistanceUnit="1" placement="2" maxCurvedCharAngleIn="20" repeatDistance="0" distInMapUnits="0" labelOffsetInMapUnits="1" xOffset="0" distMapUnitScale="0,0,0,0,0,0" predefinedPositionOrder="TR,TL,BR,BL,R,L,TSR,BSR" preserveRotation="1" repeatDistanceMapUnitScale="0,0,0,0,0,0" centroidWhole="0" priority="10" yOffset="0" offsetType="0" placementFlags="4" centroidInside="0" dist="2" angleOffset="0" maxCurvedCharAngleOut="-20" fitInPolygonOnly="0" quadOffset="4" labelOffsetMapUnitScale="0,0,0,0,0,0"/>
          <rendering fontMinPixelSize="3" scaleMax="10000000" fontMaxPixelSize="10000" scaleMin="1" upsidedownLabels="0" limitNumLabels="0" obstacle="1" obstacleFactor="2" scaleVisibility="0" fontLimitPixelSize="0" mergeLines="1" obstacleType="0" labelPerPart="0" zIndex="0" maxNumLabels="2000" displayAll="0" minFeatureSize="0"/>
          <data-defined/>
        </settings>
      </rule>
      <rule scalemaxdenom="29999" description="Lakeshore EB" filter="(dir_bin = 1) AND NOT(fcode_desc = 'Expressway')&#xd;&#xa;AND ( &quot;linear_name_full&quot; LIKE 'Lake Shore Blvd%')&#xd;&#xa;AND NOT( &quot;l2_group_number&quot; = 1258)" key="{66aa7bfd-a9e3-42ae-ab7d-3f99704f1dfe}" scalemindenom="25000">
        <settings>
          <text-style fontItalic="0" fontFamily="MS Shell Dlg 2" fontLetterSpacing="0" fontUnderline="0" fontWeight="50" fontStrikeout="0" textTransp="0" previewBkgrdColor="#ffffff" fontCapitals="0" textColor="0,0,0,255" fontSizeInMapUnits="0" isExpression="1" blendMode="0" fontSizeMapUnitScale="0,0,0,0,0,0" fontSize="12" fieldName="format_number(round(avg_vol,-1) ,0)" namedStyle="Normal" fontWordSpacing="0" useSubstitutions="0">
            <substitutions/>
          </text-style>
          <text-format placeDirectionSymbol="0" multilineAlign="0" rightDirectionSymbol=">" multilineHeight="1" plussign="0" addDirectionSymbol="0" leftDirectionSymbol="&lt;" formatNumbers="0" decimals="3" wrapChar="" reverseDirectionSymbol="0"/>
          <text-buffer bufferSize="1" bufferSizeMapUnitScale="0,0,0,0,0,0" bufferColor="255,255,255,255" bufferDraw="0" bufferBlendMode="0" bufferTransp="0" bufferSizeInMapUnits="0" bufferNoFill="0" bufferJoinStyle="64"/>
          <background shapeSizeUnits="1" shapeType="0" shapeSVGFile="" shapeOffsetX="0" shapeOffsetY="0" shapeBlendMode="0" shapeFillColor="255,255,255,255" shapeTransparency="0" shapeSizeMapUnitScale="0,0,0,0,0,0" shapeSizeType="0" shapeJoinStyle="64" shapeDraw="0" shapeBorderWidthUnits="1" shapeSizeX="0" shapeSizeY="0" shapeOffsetMapUnitScale="0,0,0,0,0,0" shapeRadiiX="0" shapeRadiiY="0" shapeOffsetUnits="1" shapeRotation="0" shapeBorderWidth="0" shapeBorderColor="128,128,128,255" shapeRotationType="0" shapeBorderWidthMapUnitScale="0,0,0,0,0,0" shapeRadiiMapUnitScale="0,0,0,0,0,0" shapeRadiiUnits="1"/>
          <shadow shadowOffsetMapUnitScale="0,0,0,0,0,0" shadowOffsetGlobal="1" shadowRadiusUnits="1" shadowTransparency="30" shadowColor="0,0,0,255" shadowUnder="0" shadowScale="100" shadowOffsetDist="1" shadowDraw="0" shadowOffsetAngle="135" shadowRadius="1.5" shadowRadiusMapUnitScale="0,0,0,0,0,0" shadowBlendMode="6" shadowRadiusAlphaOnly="0" shadowOffsetUnits="1"/>
          <placement repeatDistanceUnit="1" placement="2" maxCurvedCharAngleIn="20" repeatDistance="0" distInMapUnits="0" labelOffsetInMapUnits="1" xOffset="0" distMapUnitScale="0,0,0,0,0,0" predefinedPositionOrder="TR,TL,BR,BL,R,L,TSR,BSR" preserveRotation="1" repeatDistanceMapUnitScale="0,0,0,0,0,0" centroidWhole="0" priority="10" yOffset="0" offsetType="0" placementFlags="4" centroidInside="0" dist="2" angleOffset="0" maxCurvedCharAngleOut="-20" fitInPolygonOnly="0" quadOffset="4" labelOffsetMapUnitScale="0,0,0,0,0,0"/>
          <rendering fontMinPixelSize="3" scaleMax="30000" fontMaxPixelSize="10000" scaleMin="60000" upsidedownLabels="0" limitNumLabels="0" obstacle="1" obstacleFactor="2" scaleVisibility="0" fontLimitPixelSize="0" mergeLines="1" obstacleType="0" labelPerPart="0" zIndex="0" maxNumLabels="2000" displayAll="0" minFeatureSize="0"/>
          <data-defined/>
        </settings>
      </rule>
      <rule scalemaxdenom="29999" description="Lakeshore WB" filter="(dir_bin = -1) AND NOT(fcode_desc = 'Expressway')&#xd;&#xa;AND ( &quot;linear_name_full&quot; LIKE 'Lake Shore Blvd%')&#xd;&#xa;AND NOT( &quot;l2_group_number&quot; IN (545,1528))" key="{e79d05cb-20db-4357-b478-005c0f75ce31}" scalemindenom="25000">
        <settings>
          <text-style fontItalic="0" fontFamily="MS Shell Dlg 2" fontLetterSpacing="0" fontUnderline="0" fontWeight="50" fontStrikeout="0" textTransp="0" previewBkgrdColor="#ffffff" fontCapitals="0" textColor="0,0,0,255" fontSizeInMapUnits="0" isExpression="1" blendMode="0" fontSizeMapUnitScale="0,0,0,0,0,0" fontSize="12" fieldName="format_number(round(avg_vol,-1) ,0)" namedStyle="Normal" fontWordSpacing="0" useSubstitutions="0">
            <substitutions/>
          </text-style>
          <text-format placeDirectionSymbol="0" multilineAlign="0" rightDirectionSymbol=">" multilineHeight="1" plussign="0" addDirectionSymbol="0" leftDirectionSymbol="&lt;" formatNumbers="0" decimals="3" wrapChar="" reverseDirectionSymbol="0"/>
          <text-buffer bufferSize="1" bufferSizeMapUnitScale="0,0,0,0,0,0" bufferColor="255,255,255,255" bufferDraw="0" bufferBlendMode="0" bufferTransp="0" bufferSizeInMapUnits="0" bufferNoFill="0" bufferJoinStyle="64"/>
          <background shapeSizeUnits="1" shapeType="0" shapeSVGFile="" shapeOffsetX="0" shapeOffsetY="0" shapeBlendMode="0" shapeFillColor="255,255,255,255" shapeTransparency="0" shapeSizeMapUnitScale="0,0,0,0,0,0" shapeSizeType="0" shapeJoinStyle="64" shapeDraw="0" shapeBorderWidthUnits="1" shapeSizeX="0" shapeSizeY="0" shapeOffsetMapUnitScale="0,0,0,0,0,0" shapeRadiiX="0" shapeRadiiY="0" shapeOffsetUnits="1" shapeRotation="0" shapeBorderWidth="0" shapeBorderColor="128,128,128,255" shapeRotationType="0" shapeBorderWidthMapUnitScale="0,0,0,0,0,0" shapeRadiiMapUnitScale="0,0,0,0,0,0" shapeRadiiUnits="1"/>
          <shadow shadowOffsetMapUnitScale="0,0,0,0,0,0" shadowOffsetGlobal="1" shadowRadiusUnits="1" shadowTransparency="30" shadowColor="0,0,0,255" shadowUnder="0" shadowScale="100" shadowOffsetDist="1" shadowDraw="0" shadowOffsetAngle="135" shadowRadius="1.5" shadowRadiusMapUnitScale="0,0,0,0,0,0" shadowBlendMode="6" shadowRadiusAlphaOnly="0" shadowOffsetUnits="1"/>
          <placement repeatDistanceUnit="1" placement="2" maxCurvedCharAngleIn="20" repeatDistance="0" distInMapUnits="0" labelOffsetInMapUnits="1" xOffset="0" distMapUnitScale="0,0,0,0,0,0" predefinedPositionOrder="TR,TL,BR,BL,R,L,TSR,BSR" preserveRotation="1" repeatDistanceMapUnitScale="0,0,0,0,0,0" centroidWhole="0" priority="10" yOffset="0" offsetType="0" placementFlags="4" centroidInside="0" dist="2" angleOffset="0" maxCurvedCharAngleOut="-20" fitInPolygonOnly="0" quadOffset="4" labelOffsetMapUnitScale="0,0,0,0,0,0"/>
          <rendering fontMinPixelSize="3" scaleMax="30000" fontMaxPixelSize="10000" scaleMin="60000" upsidedownLabels="0" limitNumLabels="0" obstacle="1" obstacleFactor="2" scaleVisibility="0" fontLimitPixelSize="0" mergeLines="1" obstacleType="0" labelPerPart="0" zIndex="0" maxNumLabels="2000" displayAll="0" minFeatureSize="0"/>
          <data-defined/>
        </settings>
      </rule>
      <rule scalemaxdenom="25000" description="Downtown EB NB" filter="(dir_bin = 1) AND NOT(fcode_desc = 'Expressway' AND NOT(&quot;linear_name_full&quot;  LIKE  'Don Valley Parkway%'))&#xd;&#xa;AND NOT(&quot;linear_name_full&quot; LIKE '%Drumsnab%' OR &quot;linear_name_full&quot; LIKE '%Castle Frank%')&#xd;&#xa;AND NOT(&quot;l2_group_number&quot; IN (30706))" key="{456fb5b7-0f15-4e3b-be58-e3c772955153}" scalemindenom="1000">
        <settings>
          <text-style fontItalic="0" fontFamily="Arial Narrow" fontLetterSpacing="0" fontUnderline="0" fontWeight="50" fontStrikeout="0" textTransp="0" previewBkgrdColor="#ffffff" fontCapitals="0" textColor="0,0,0,255" fontSizeInMapUnits="0" isExpression="1" blendMode="0" fontSizeMapUnitScale="0,0,0,0,0,0" fontSize="10" fieldName="format_number(round(avg_vol,-1) ,0)" namedStyle="Normal" fontWordSpacing="0" useSubstitutions="0">
            <substitutions/>
          </text-style>
          <text-format placeDirectionSymbol="0" multilineAlign="0" rightDirectionSymbol=">" multilineHeight="1" plussign="0" addDirectionSymbol="0" leftDirectionSymbol="&lt;" formatNumbers="0" decimals="3" wrapChar="" reverseDirectionSymbol="0"/>
          <text-buffer bufferSize="1" bufferSizeMapUnitScale="0,0,0,0,0,0" bufferColor="255,255,255,255" bufferDraw="0" bufferBlendMode="0" bufferTransp="0" bufferSizeInMapUnits="0" bufferNoFill="0" bufferJoinStyle="64"/>
          <background shapeSizeUnits="1" shapeType="0" shapeSVGFile="" shapeOffsetX="0" shapeOffsetY="0" shapeBlendMode="0" shapeFillColor="255,255,255,255" shapeTransparency="0" shapeSizeMapUnitScale="0,0,0,0,0,0" shapeSizeType="0" shapeJoinStyle="64" shapeDraw="0" shapeBorderWidthUnits="1" shapeSizeX="0" shapeSizeY="0" shapeOffsetMapUnitScale="0,0,0,0,0,0" shapeRadiiX="0" shapeRadiiY="0" shapeOffsetUnits="1" shapeRotation="0" shapeBorderWidth="0" shapeBorderColor="128,128,128,255" shapeRotationType="0" shapeBorderWidthMapUnitScale="0,0,0,0,0,0" shapeRadiiMapUnitScale="0,0,0,0,0,0" shapeRadiiUnits="1"/>
          <shadow shadowOffsetMapUnitScale="0,0,0,0,0,0" shadowOffsetGlobal="1" shadowRadiusUnits="1" shadowTransparency="30" shadowColor="0,0,0,255" shadowUnder="0" shadowScale="100" shadowOffsetDist="1" shadowDraw="0" shadowOffsetAngle="135" shadowRadius="1.5" shadowRadiusMapUnitScale="0,0,0,0,0,0" shadowBlendMode="6" shadowRadiusAlphaOnly="0" shadowOffsetUnits="1"/>
          <placement repeatDistanceUnit="1" placement="2" maxCurvedCharAngleIn="20" repeatDistance="0" distInMapUnits="0" labelOffsetInMapUnits="1" xOffset="0" distMapUnitScale="0,0,0,0,0,0" predefinedPositionOrder="TR,TL,BR,BL,R,L,TSR,BSR" preserveRotation="1" repeatDistanceMapUnitScale="0,0,0,0,0,0" centroidWhole="0" priority="5" yOffset="0" offsetType="0" placementFlags="4" centroidInside="0" dist="0" angleOffset="0" maxCurvedCharAngleOut="-20" fitInPolygonOnly="0" quadOffset="4" labelOffsetMapUnitScale="0,0,0,0,0,0"/>
          <rendering fontMinPixelSize="3" scaleMax="10000000" fontMaxPixelSize="10000" scaleMin="1" upsidedownLabels="0" limitNumLabels="0" obstacle="0" obstacleFactor="1" scaleVisibility="0" fontLimitPixelSize="0" mergeLines="1" obstacleType="0" labelPerPart="0" zIndex="0" maxNumLabels="2000" displayAll="0" minFeatureSize="9"/>
          <data-defined/>
        </settings>
      </rule>
      <rule scalemaxdenom="25000" description="Downtown WB SB" filter="(dir_bin = -1) AND NOT(fcode_desc = 'Expressway' AND NOT(&quot;linear_name_full&quot;  LIKE  'Don Valley Parkway%'))&#xd;&#xa;AND NOT(&quot;linear_name_full&quot; LIKE '%Drumsnab%' OR &quot;linear_name_full&quot; LIKE '%Castle Frank%')&#xd;&#xa;AND NOT(&quot;l2_group_number&quot; IN (30583))" key="{a6f304f6-9cf8-4771-8479-b21a9f054909}" scalemindenom="1000">
        <settings>
          <text-style fontItalic="0" fontFamily="Arial Narrow" fontLetterSpacing="0" fontUnderline="0" fontWeight="50" fontStrikeout="0" textTransp="0" previewBkgrdColor="#ffffff" fontCapitals="0" textColor="0,0,0,255" fontSizeInMapUnits="0" isExpression="1" blendMode="0" fontSizeMapUnitScale="0,0,0,0,0,0" fontSize="10" fieldName="format_number(round(avg_vol,-1) ,0)" namedStyle="Normal" fontWordSpacing="0" useSubstitutions="0">
            <substitutions/>
          </text-style>
          <text-format placeDirectionSymbol="0" multilineAlign="0" rightDirectionSymbol=">" multilineHeight="1" plussign="0" addDirectionSymbol="0" leftDirectionSymbol="&lt;" formatNumbers="0" decimals="3" wrapChar="" reverseDirectionSymbol="0"/>
          <text-buffer bufferSize="1" bufferSizeMapUnitScale="0,0,0,0,0,0" bufferColor="255,255,255,255" bufferDraw="0" bufferBlendMode="0" bufferTransp="0" bufferSizeInMapUnits="0" bufferNoFill="0" bufferJoinStyle="64"/>
          <background shapeSizeUnits="1" shapeType="0" shapeSVGFile="" shapeOffsetX="0" shapeOffsetY="0" shapeBlendMode="0" shapeFillColor="255,255,255,255" shapeTransparency="0" shapeSizeMapUnitScale="0,0,0,0,0,0" shapeSizeType="0" shapeJoinStyle="64" shapeDraw="0" shapeBorderWidthUnits="1" shapeSizeX="0" shapeSizeY="0" shapeOffsetMapUnitScale="0,0,0,0,0,0" shapeRadiiX="0" shapeRadiiY="0" shapeOffsetUnits="1" shapeRotation="0" shapeBorderWidth="0" shapeBorderColor="128,128,128,255" shapeRotationType="0" shapeBorderWidthMapUnitScale="0,0,0,0,0,0" shapeRadiiMapUnitScale="0,0,0,0,0,0" shapeRadiiUnits="1"/>
          <shadow shadowOffsetMapUnitScale="0,0,0,0,0,0" shadowOffsetGlobal="1" shadowRadiusUnits="1" shadowTransparency="30" shadowColor="0,0,0,255" shadowUnder="0" shadowScale="100" shadowOffsetDist="1" shadowDraw="0" shadowOffsetAngle="135" shadowRadius="1.5" shadowRadiusMapUnitScale="0,0,0,0,0,0" shadowBlendMode="6" shadowRadiusAlphaOnly="0" shadowOffsetUnits="1"/>
          <placement repeatDistanceUnit="1" placement="2" maxCurvedCharAngleIn="20" repeatDistance="0" distInMapUnits="0" labelOffsetInMapUnits="1" xOffset="0" distMapUnitScale="0,0,0,0,0,0" predefinedPositionOrder="TR,TL,BR,BL,R,L,TSR,BSR" preserveRotation="1" repeatDistanceMapUnitScale="0,0,0,0,0,0" centroidWhole="0" priority="5" yOffset="0" offsetType="0" placementFlags="4" centroidInside="0" dist="0" angleOffset="0" maxCurvedCharAngleOut="-20" fitInPolygonOnly="0" quadOffset="4" labelOffsetMapUnitScale="0,0,0,0,0,0"/>
          <rendering fontMinPixelSize="3" scaleMax="10000000" fontMaxPixelSize="10000" scaleMin="1" upsidedownLabels="0" limitNumLabels="0" obstacle="0" obstacleFactor="1" scaleVisibility="0" fontLimitPixelSize="0" mergeLines="1" obstacleType="0" labelPerPart="0" zIndex="0" maxNumLabels="2000" displayAll="0" minFeatureSize="9"/>
          <data-defined/>
        </settings>
      </rule>
    </rules>
  </labeling>
  <customproperties>
    <property key="embeddedWidgets/count" value="0"/>
    <property key="variableNames"/>
    <property key="variableValues"/>
  </customproperties>
  <blendMode>0</blendMode>
  <featureBlendMode>0</featureBlendMode>
  <layerTransparency>0</layerTransparency>
  <displayfield>linear_name_full</displayfield>
  <label>0</label>
  <labelattributes>
    <label fieldname="" text="Label"/>
    <family fieldname="" name="MS Shell Dlg 2"/>
    <size fieldname="" units="pt" value="12"/>
    <bold fieldname="" on="0"/>
    <italic fieldname="" on="0"/>
    <underline fieldname="" on="0"/>
    <strikeout fieldname="" on="0"/>
    <color fieldname="" red="0" blue="0" green="0"/>
    <x fieldname=""/>
    <y fieldname=""/>
    <offset x="0" y="0" units="pt" yfieldname="" xfieldname=""/>
    <angle fieldname="" value="0" auto="0"/>
    <alignment fieldname="" value="center"/>
    <buffercolor fieldname="" red="255" blue="255" green="255"/>
    <buffersize fieldname="" units="pt" value="1"/>
    <bufferenabled fieldname="" on=""/>
    <multilineenabled fieldname="" on=""/>
    <selectedonly on=""/>
  </labelattributes>
  <SingleCategoryDiagramRenderer diagramType="Histogram" sizeLegend="0" attributeLegend="1">
    <DiagramCategory penColor="#000000" labelPlacementMethod="XHeight" penWidth="0" diagramOrientation="Up" sizeScale="0,0,0,0,0,0" minimumSize="0" barWidth="5" penAlpha="255" maxScaleDenominator="1e+08" backgroundColor="#ffffff" transparency="0" width="15" scaleDependency="Area" backgroundAlpha="255" angleOffset="1440" scaleBasedVisibility="0" enabled="0" height="15" lineSizeScale="0,0,0,0,0,0" sizeType="MM" lineSizeType="MM" minScaleDenominator="inf">
      <fontProperties description="MS Shell Dlg 2,8.25,-1,5,50,0,0,0,0,0" style=""/>
      <attribute field="" color="#000000" label=""/>
    </DiagramCategory>
    <symbol alpha="1" clip_to_extent="1" type="marker" name="sizeSymbol">
      <layer pass="0" class="SimpleMarker" locked="0">
        <prop k="angle" v="0"/>
        <prop k="color" v="255,0,0,255"/>
        <prop k="horizontal_anchor_point" v="1"/>
        <prop k="joinstyle" v="bevel"/>
        <prop k="name" v="circle"/>
        <prop k="offset" v="0,0"/>
        <prop k="offset_map_unit_scale" v="0,0,0,0,0,0"/>
        <prop k="offset_unit" v="MM"/>
        <prop k="outline_color" v="0,0,0,255"/>
        <prop k="outline_style" v="solid"/>
        <prop k="outline_width" v="0"/>
        <prop k="outline_width_map_unit_scale" v="0,0,0,0,0,0"/>
        <prop k="outline_width_unit" v="MM"/>
        <prop k="scale_method" v="diameter"/>
        <prop k="size" v="2"/>
        <prop k="size_map_unit_scale" v="0,0,0,0,0,0"/>
        <prop k="size_unit" v="MM"/>
        <prop k="vertical_anchor_point" v="1"/>
      </layer>
    </symbol>
  </SingleCategoryDiagramRenderer>
  <DiagramLayerSettings yPosColumn="-1" showColumn="-1" linePlacementFlags="10" placement="2" dist="0" xPosColumn="-1" priority="0" obstacle="0" zIndex="0" showAll="1"/>
  <annotationform>.</annotationform>
  <aliases>
    <alias field="l2_group_number" index="0" name=""/>
    <alias field="linear_name_full" index="1" name=""/>
    <alias field="fcode_desc" index="2" name=""/>
    <alias field="dir_bin" index="3" name=""/>
    <alias field="year" index="4" name=""/>
    <alias field="avg_vol" index="5" name=""/>
  </aliases>
  <excludeAttributesWMS/>
  <excludeAttributesWFS/>
  <attributeactions default="-1"/>
  <attributetableconfig actionWidgetStyle="dropDown" sortExpression="" sortOrder="0">
    <columns>
      <column width="-1" hidden="0" type="field" name="l2_group_number"/>
      <column width="-1" hidden="0" type="field" name="linear_name_full"/>
      <column width="-1" hidden="0" type="field" name="fcode_desc"/>
      <column width="-1" hidden="0" type="field" name="dir_bin"/>
      <column width="-1" hidden="0" type="field" name="year"/>
      <column width="-1" hidden="0" type="field" name="avg_vol"/>
      <column width="-1" hidden="1" type="actions"/>
    </columns>
  </attributetableconfig>
  <editform>.</editform>
  <editforminit/>
  <editforminitcodesource>0</editforminitcodesource>
  <editforminitfilepath>.</editforminitfilepath>
  <editforminitcode><![CDATA[# -*- coding: utf-8 -*-
"""
QGIS forms can have a Python function that is called when the form is
opened.

Use this function to add extra logic to your forms.

Enter the name of the function in the "Python Init function"
field.
An example follows:
"""
from PyQt4.QtGui import QWidget

def my_form_open(dialog, layer, feature):
	geom = feature.geometry()
	control = dialog.findChild(QWidget, "MyLineEdit")
]]></editforminitcode>
  <featformsuppress>0</featformsuppress>
  <editorlayout>generatedlayout</editorlayout>
  <widgets/>
  <conditionalstyles>
    <rowstyles/>
    <fieldstyles/>
  </conditionalstyles>
  <defaults>
    <default field="l2_group_number" expression=""/>
    <default field="linear_name_full" expression=""/>
    <default field="fcode_desc" expression=""/>
    <default field="dir_bin" expression=""/>
    <default field="year" expression=""/>
    <default field="avg_vol" expression=""/>
  </defaults>
  <previewExpression>COALESCE( "linear_name_full", '&lt;NULL>' )</previewExpression>
  <layerGeometryType>1</layerGeometryType>
</qgis>
