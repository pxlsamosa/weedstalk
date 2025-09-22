extends Resource
class_name PlantResource
#PlantResource.gd 
#This is like a plant template

@export var plant_id: String = "" ## plant's id for calling via code plant_name or plant_1 etc.
@export var plant_name: String = "" ## plant's player facing name Plant Name or Plant 1 etc.
@export var min_yield: int = 100
@export var max_yield: int = 400
