#-----------------------------------------------------------------------------
#
# Orignal code by: CptanPanic 
#
# THIS SOFTWARE IS PROVIDED "AS IS" AND WITHOUT ANY EXPRESS OR
# IMPLIED WARRANTIES, INCLUDING, WITHOUT LIMITATION, THE IMPLIED
# WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE.
#
#-----------------------------------------------------------------------------
# Name        : dimensions_info.rb
# Type        : Tool
# Description : Displays Dimensions of Component.
# Menu Item   : Plugins -> Get Component Dimensions.
# Context-Menu: None
# Author      : XboxHacker
# Usage       : Select Component, and call script.
# Date        : December 2016
# Version     :	1.0			Initial Release.
#
#             : Based on code by Jim. Modifed by Xboxhacker
#               returns "true" dimensions for rotated and scaled Group and Instance.
#		NEW - HTML Dialog box, selectable text within box.
#		NEW - Color coded text for each axis
#-----------------------------------------------------------------------------
	
		
 require 'sketchup.rb'
 
 module XBOXHACKER
     module DimensionsInfo
         module_function
         def dimensions_info
 
             model = Sketchup.active_model
             selection = model.selection
 
             ### show VCB and status info...
             Sketchup::set_status_text(("DIMENSIONS..." ), SB_PROMPT)
             Sketchup::set_status_text(" ", SB_VCB_LABEL)
             Sketchup::set_status_text(" ", SB_VCB_VALUE)
 
             ### Get Selected Entities.
             return unless selection.length == 1
             e = selection[0]
             return unless e.respond_to?(:transformation)
 
             scale_x = ((Geom::Vector3d.new 1,0,0).transform! e.transformation).length
             scale_y = ((Geom::Vector3d.new 0,1,0).transform! e.transformation).length
             scale_z = ((Geom::Vector3d.new 0,0,1).transform! e.transformation).length
 
             bb = nil
             if e.is_a? Sketchup::Group
                 bb = Geom::BoundingBox.new
                 e.entities.each {|en| bb.add(en.bounds) }
             elsif e.is_a? Sketchup::ComponentInstance
                 bb = e.definition.bounds
             end
 
             if bb
                 dims = [
                     width  = bb.width  * scale_x,
                     height = bb.height * scale_y,
                     depth  = bb.depth  * scale_z
                 ]
 								
 				
 				#---------------START HTML BOX-------------------------
 					html = <<-'00HERE!!'
						<html>
						    <meta http-equiv="X-UA-Compatible" content="IE=edge"/>
						    <head>
						        <title>Dimension Info</title>
						        <style type="text/css">
						            table {border:1px solid black; border-collapse:collapse;}
						            td    {border:1px solid black; padding:0.5em 1em 0.5em 1em;}
						        </style>
						    </head>
						    <body>  
						        <table>
							            <tr><td><b><font size="4" color="red">Width:  </font></b></td><td>_0</td></tr>
							            <tr><td><b><font size="4" color="blue">Height: </font></b></td><td>_1</td></tr>
							            <tr><td><b><font size="4" color="green">Depth:  </font></b></td><td>_2</td></tr>
				        		</table>
				        		</br>
						       <button onclick="window.location.href='skp:closeDialog@true'">CLOSE</button>
						    </body>
						</html>
						00HERE!!
						
						# below replaces placeholders inside of td elements
						html.sub!(/_0/, "\t#{dims[0].to_l}")
						
						
						html.sub!(/_1/, "\t#{dims[1].to_l}")
						
						
						html.sub!(/_2/, "\t#{dims[2].to_l}")
						
						
						
						wd = UI::WebDialog.new("Dimension Info", false, "", 250, 200, 100, 100, false )
						wd.add_action_callback("closeDialog") {|dialog, action| 
						
						 wd.close
						 }
						 
						wd.set_html(html)
		wd.show()
             end
         end
     end
 end
 
 ### do menu
 
 if( not file_loaded?("dimensions_info.rb") )
     add_separator_to_menu("Plugins")
 	menu_name = "Dimensions Info"
     UI.menu("Plugins").add_item(menu_name) { XBOXHACKER::DimensionsInfo.dimensions_info }
 end#if
file_loaded("dimensions_info.rb")

