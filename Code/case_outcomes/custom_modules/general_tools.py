import os, string

def read_json_dict(path: str) -> dict:
    """
    Reads a json file and returns it as dict object
    """
    
    file = open(path) # Opening JSON file
    return json.load(file) # returns JSON object as a dictionary


def folder_creator(folder_name: string, path: string) -> None:
    """
    Generates a folder in specified path
    
    input: name of root folder, path where you want 
    folder to be created
    output: None
    """
    
    # defining paths
    data_folder_path = path + "/" + folder_name
    data_folder_exists = os.path.exists(data_folder_path)

    # creating folders if don't exist
    if data_folder_exists:
        pass
    else:    
        # create a new directory because it does not exist 
        os.makedirs(data_folder_path)

        # create subfolders
        print(f"The new directory {folder_name} was created!")