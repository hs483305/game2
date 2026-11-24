"""Create an original low-poly diver prop and a small Blue Hole scene."""
import bpy
import math
import os
from mathutils import Vector

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
ASSETS = os.path.join(ROOT, "assets")
os.makedirs(ASSETS, exist_ok=True)
bpy.ops.object.select_all(action="SELECT")
bpy.ops.object.delete(use_global=False)

def mat(name, color, metallic=0.0, roughness=0.55):
    m = bpy.data.materials.new(name)
    m.diffuse_color = (*color, 1)
    m.use_nodes = True
    bsdf = m.node_tree.nodes.get("Principled BSDF")
    bsdf.inputs["Base Color"].default_value = (*color, 1)
    bsdf.inputs["Metallic"].default_value = metallic
    bsdf.inputs["Roughness"].default_value = roughness
    return m

teal = mat("Lagoon enamel", (0.12, 0.72, 0.69), 0.24)
yellow = mat("Sunlit brass", (0.96, 0.64, 0.2), 0.52, 0.33)
coral = mat("Warm coral suit", (0.94, 0.35, 0.23), 0.05)
dark = mat("Deep navy", (0.025, 0.105, 0.16), 0.13)
glass = mat("Sea glass", (0.37, 0.83, 0.87), 0.25, 0.19)
ivory = mat("Pearl white", (0.92, 0.9, 0.75), 0.1)
rock = mat("Blue slate", (0.08, 0.23, 0.31))
coral_pink = mat("Rose coral", (0.94, 0.25, 0.4))

def uv(name, location, scale, material, segments=16, rings=10):
    bpy.ops.mesh.primitive_uv_sphere_add(segments=segments, ring_count=rings, radius=1, location=location)
    obj = bpy.context.object
    obj.name = name
    obj.scale = scale
    bpy.ops.object.shade_smooth()
    obj.data.materials.append(material)
    return obj

def cylinder(name, location, radius, depth, material, vertices=12, rotation=None):
    bpy.ops.mesh.primitive_cylinder_add(vertices=vertices, radius=radius, depth=depth, location=location, rotation=rotation or (0,0,0))
    obj=bpy.context.object; obj.name=name; obj.data.materials.append(material
    )
    bevel=obj.modifiers.new("Soft toy-like edges", "BEVEL"); bevel.width=0.035; bevel.segments=2
    obj.modifiers.new("Weighted normals", "WEIGHTED_NORMAL")
    return obj

def cone(name, location, radius1, radius2, depth, material, vertices=8, rotation=None):
    bpy.ops.mesh.primitive_cone_add(vertices=vertices, radius1=radius1, radius2=radius2, depth=depth, location=location, rotation=rotation or (0,0,0))
    obj=bpy.context.object; obj.name=name; obj.data.materials.append(material)
    return obj

# A small, assembled diver character. Local +Z points upward; X is the swim axis.
diver_objects=[]
def remember(obj): diver_objects.append(obj); return obj
remember(uv("Diver | glazed helmet", (0,0,1.18), (.47,.43,.47), yellow))
remember(uv("Diver | porthole", (.07,-.365,1.2), (.26,.095,.25), glass))
remember(uv("Diver | shadowed face", (.11,-.444,1.2), (.13,.035,.13), dark))
remember(uv("Diver | body", (0,0,.47), (.34,.33,.52), coral))
remember(cylinder("Diver | air tank", (-.39,.08,.54), .19,.78,teal))
remember(uv("Diver | tank cap",(-.39,.08,.95),(.17,.17,.09),yellow))
# legs and soft triangular fins
for side in [-1,1]:
    remember(uv("Diver | flipper leg", (.17*side,0,.02),(.16,.17,.33),dark))
    obj=remember(cone("Diver | swim fin", (.37*side,-.015,-.2), .24,.1,.53,teal, vertices=6, rotation=(0,math.radians(90*side),0)))
    remember(uv("Diver | glove", (.27*side,-.02,.52),(.13,.14,.14),yellow))
# small regulator and belt details
remember(uv("Diver | breathing valve",(-.28,-.35,.9),(.11,.08,.12),yellow))
remember(cylinder("Diver | belt clasp",(0,-.333,.33),.06,.035,ivory,vertices=8,rotation=(math.pi/2,0,0)))

# Export only the character meshes, leaving the scene environment out of the asset.
bpy.ops.object.select_all(action="DESELECT")
for obj in diver_objects: obj.select_set(True)
bpy.context.view_layer.objects.active = diver_objects[0]
bpy.ops.export_scene.gltf(filepath=os.path.join(ASSETS,"little_diver.glb"), export_format="GLB", use_selection=True, export_apply=True)

# Add an authored mini diorama to the editable Blender scene.
ground=cylinder("Diorama | stone plinth",(0,0,-.53),3.8,.42,rock,vertices=12)
ground.scale.y=.68
uv("Diorama | luminous pearl",(2.1,-.45,-.13),(.28,.28,.28),ivory)
for x,y,z in [(-2.5,-.2,-.2),(-1.7,-.35,-.2),(2.6,.25,-.2)]:
    uv("Diorama | rose coral",(x,y,z),(.38,.25,.28),coral_pink,12,8)
    for j in range(3):
        cone("Diorama | coral branch",(x+(j-1)*.16,y,z+.35),.11,.035,.58,coral_pink,6,rotation=(0,.24*(j-1),0))
for i in range(8):
    x=-3.15+i*.86
    cone("Diorama | sea grass",(x,.28,-.02+(i%2)*.06),.12,.018,.86,teal,6,rotation=(.18*(i%3-1),.24*((i%2)*2-1),0))

# Studio camera and lighting for a useful starting view when opening the .blend.
world=bpy.context.scene.world or bpy.data.worlds.new("Blue Hole ambience")
bpy.context.scene.world=world; world.color=(.035,.11,.19)
world.use_nodes=True; world.node_tree.nodes["Background"].inputs["Color"].default_value=(.035,.11,.19,1); world.node_tree.nodes["Background"].inputs["Strength"].default_value=.42
bpy.ops.object.light_add(type="AREA", location=(1.5,-4.2,6.0)); key=bpy.context.object; key.name="Softbox | lagoon sun"; key.data.energy=470; key.data.shape="DISK"; key.data.size=5
bpy.ops.object.light_add(type="AREA", location=(-4,1,2.4)); fill=bpy.context.object; fill.name="Softbox | cool fill"; fill.data.energy=280; fill.data.color=(.35,.8,1); fill.data.size=4
bpy.ops.object.camera_add(location=(5.7,-8.8,5.3)); camera=bpy.context.object; camera.name="Camera | Blue Hole diorama"; camera.rotation_euler=(Vector((0,0,.2))-camera.location).to_track_quat("-Z","Y").to_euler()
scene=bpy.context.scene; scene.camera=camera; scene.render.engine="CYCLES"; scene.cycles.samples=32
scene.render.resolution_x=1000; scene.render.resolution_y=740; scene.render.resolution_percentage=100
scene.render.image_settings.file_format="PNG"; scene.view_settings.view_transform="AgX"
bpy.ops.wm.save_as_mainfile(filepath=os.path.join(ROOT,"blender","blue_hole_scene.blend"))
print("Saved Blender scene and assets/little_diver.glb")
