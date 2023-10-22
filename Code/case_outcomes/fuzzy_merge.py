import pickle
import regex as re
import pandas as pd
import numpy as np
import json, os, string
from janitor import clean_names
import d6tjoin.top1
import d6tjoin.utils
import d6tjoin

def extract_text(text: str, pattern: str) -> str:
    """Extracts substring from string using a given regex pattern"""
    
    if type(text) is str:
        match = re.search(pattern, text)
        if match:
            return match.group(1)
        else:
            return ""
    else:
        return ""


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
    
    
def create_pickle(object_name, file_name: str, path: str) -> None:
    """
    Creates a pickle file for object. Note: Path should have no slash 
    at the end
    """
    with open(path + f"/{file_name}", "wb") as storing_output:
        pickle.dump(object_name, storing_output)
        storing_output.close()


def read_pickle(file_name: str, path: str) -> None:
    """
    Reads pickle file from specified path 
    """
    pickle_file = open(path + f"/{file_name}", "rb")
    output = pickle.load(pickle_file)
    pickle_file.close()
    return output


if __name__ == "__main__":
    # reading folders
    paths = read_json_dict("paths.json")
    data_path = paths["data_path"]

    # creating folders
    folder_creator("data_cleaned_test", data_path)
    data_cleaned_path = data_path + "/data_cleaned_test"
    folder_creator("raw", data_cleaned_path)
    dc_raw_path = data_cleaned_path + "/raw"
    folder_creator("temp", data_cleaned_path)
    dc_temp_path = data_cleaned_path + "/temp"
    folder_creator("intermediate", data_cleaned_path)
    dc_interm_path = data_cleaned_path + "/intermediate"
    folder_creator("final", data_cleaned_path)
    dc_final_path = data_cleaned_path + "/final"

    # loading lab data
    # lab_data_path = input("Please, input the path to your data file as dta (e.g. path/lab_data.dta)") # data_path + "/lab_Data/Clean_Full_Data12.dta"
    lab_data_path = data_path + "/lab_data/Clean_Full_Data12_filtered.dta"
    lab_data = pd.read_stata(lab_data_path)
    
    # creating the combinations 
    lab_data["participant_nombre_apellido"] = lab_data["Nombres"] + " " + lab_data["ApellidoPaterno"] + " " + lab_data["ApellidoMaterno"]
    lab_data["participant_nombre_apellido"] = lab_data["participant_nombre_apellido"].str.strip()
    lab_data["participant_apellido_nombre"] = lab_data["ApellidoPaterno"] + " " + lab_data["ApellidoMaterno"] + " " + lab_data["Nombres"]
    lab_data["participant_apellido_nombre"] = lab_data["participant_apellido_nombre"].str.strip()

    # preparing lab data for fuzzy merge
    lab_data = lab_data.rename(columns={"DNI": "nrodocumento"})
    exp_participants = lab_data[["nrodocumento", "participant_nombre_apellido", "participant_apellido_nombre"]]
    exp_participants.to_csv(dc_raw_path + "/exp_participants_list.csv")

    # obtaining names from cases
    files_reports = pd.read_csv(dc_raw_path + "/2022/DF_file_report_2022.csv")
    files_reports = clean_names(files_reports)

    # cleaning names from cases data
    backslash_reps = ["\\(\\*\\)", "\\", "\\([^()]{0,}\\)"]
    trailing_and_special_reps = ["^\\s", "\\,", "\\.$", " \\- JUZ$", "\\*"]
    other_strs_reps = ["\\- MIXTO Y LIQ", "\\- MIXTO", "\\- JUZ\\. MIXTO", 
                    "- JM", "- INVESTIGACION", "- PAZ LETRADO", "SECOM - ", "- JT"]
    empty_reps = backslash_reps + trailing_and_special_reps + other_strs_reps

    for val in empty_reps: # erasing unnecessary characters
        files_reports["juez_"] = files_reports["juez_"].str.replace(val, "")

    name_reps = [["ALFREDO E\\.", "ALFREDO E"], ["BERTHA F\\.", "BERTHA F"], ["CLAUDIO W\\.", "CLAUDIO W"], 
            ["CLAVELITO L\\.", "CLAVELITO L"], ["ELMER L\\.", "ELMER L"], ["ERNESTO A\\.", "ERNESTO A"],
            ["HERBERT M\\.", "HERBERT M"], ["LUZ K\\.", "LUZ K"], ["NANCY S\\.", "NANCY S"], ["JESSICA E\\.", "JESSICA E"],
            ["PATRICIA C\\.", "PATRICIA C"], ["JESSICA P\\.", "JESSICA P"], ["YOLANDA B\\.", "YOLANDA B\\."],
            ["LUZ M\\.", "LUZ M"], ["EDGAR\\.", "EDGAR"], ["C\\. ARTURO", "C ARTURO"], ["ALEXANDER A\\.", "ALEXANDER A"],
            ["RENE G\\.", "RENE G"], ["GUILLERMO S\\.", "GUILLERMO S"], ["FANNY L\\. ",  "FANNY L"], ["ELISA \\(LA", "ELISA"],
            ["JULIA \\(LA", "JULIA"], ["ACEVEDO DIEZ CECILIA", "ACEVEDO DIEZ CECILIA DEL PILAR"], [" J. ", " J "],
            [" K. ", " K "]]
    
    for name_rep in name_reps: # replacing names with issues
        files_reports["juez_"] = files_reports["juez_"].str.replace(name_rep[0], name_rep[1])

    files_reports = files_reports[files_reports["juez_"].notna()] # keeping cases with not empty judges
    files_reports["juez_splitted"] = files_reports["juez_"].apply(lambda row: row.split("."))
    files_reports["n_judges_case"] = files_reports["juez_splitted"].apply(lambda row: len(row))

    judge_names = files_reports[files_reports["n_judges_case"] == 1] # cases with a single judge name
    judge_names = judge_names.rename(columns={"juez_": "juez"})
    judge_names_only = judge_names[["juez"]]
    judge_names_only = judge_names_only.drop_duplicates()

    # obtaining names of multiple judges
    multiple_judge_names = files_reports[files_reports["n_judges_case"] != 1] # cases w multiple judges
    multiple_judge_names["juez_1"] = multiple_judge_names["juez_splitted"].apply(lambda row: row[0]) 
    multiple_judge_names["juez_2"] = multiple_judge_names["juez_splitted"].apply(lambda row: row[1] if len(row) > 1 else np.NaN)
    multiple_judge_names["juez_3"] = multiple_judge_names["juez_splitted"].apply(lambda row: row[2] if len(row) > 2 else np.NaN)
    multiple_judge_names["juez_4"] = multiple_judge_names["juez_splitted"].apply(lambda row: row[3] if len(row) > 3 else np.NaN)
    multiple_judge_names["juez_5"] = multiple_judge_names["juez_splitted"].apply(lambda row: row[4] if len(row) > 4 else np.NaN)
    multiple_judge_names["juez_6"] = multiple_judge_names["juez_splitted"].apply(lambda row: row[5] if len(row) > 5 else np.NaN)

    # keeping for the fuzzy merge only obs that can't be matched directly
    judge_names_only = judge_names["juez"].reset_index() # erasing duplicates from judges in cases
    judge_names_only = judge_names_only.drop_duplicates(subset=["juez"])
    multiple_judge_names_1 = multiple_judge_names["juez_1"].reset_index()
    multiple_judge_names_1 = multiple_judge_names_1.drop_duplicates(subset=["juez_1"])
    multiple_judge_names_1 = multiple_judge_names_1[multiple_judge_names_1["juez_1"].notna()]
    multiple_judge_names_2 = multiple_judge_names["juez_2"].reset_index()
    multiple_judge_names_2 = multiple_judge_names_2.drop_duplicates(subset=["juez_2"])
    multiple_judge_names_2 = multiple_judge_names_2[multiple_judge_names_2["juez_2"].notna()]
    multiple_judge_names_3 = multiple_judge_names["juez_3"].reset_index()
    multiple_judge_names_3 = multiple_judge_names_3.drop_duplicates(subset=["juez_3"])
    multiple_judge_names_3 = multiple_judge_names_3[multiple_judge_names_3["juez_3"].notna()]
    multiple_judge_names_4 = multiple_judge_names["juez_4"].reset_index()
    multiple_judge_names_4 = multiple_judge_names_4.drop_duplicates(subset=["juez_4"])
    multiple_judge_names_4 = multiple_judge_names_4[multiple_judge_names_4["juez_4"].notna()]
    multiple_judge_names_5 = multiple_judge_names["juez_5"].reset_index()
    multiple_judge_names_5 = multiple_judge_names_5.drop_duplicates(subset=["juez_5"])
    multiple_judge_names_5 = multiple_judge_names_5[multiple_judge_names_5["juez_5"].notna()]
    multiple_judge_names_6 = multiple_judge_names["juez_6"].reset_index()
    multiple_judge_names_6 = multiple_judge_names_6.drop_duplicates(subset=["juez_6"])
    multiple_judge_names_6 = multiple_judge_names_6[multiple_judge_names_6["juez_6"].notna()]

    # dropping duplicates in judges from lab data based on nombre_apellido
    nombre_apellido_merge = pd.merge(judge_names_only, exp_participants, left_on="juez", right_on="participant_nombre_apellido")
    nombre_apellido_merge = nombre_apellido_merge.drop_duplicates(subset=["juez"])
    nombre_apellido_merge.to_excel(dc_interm_path + "/nombre_apellido_merge.xlsx")

    # dropping duplicates in judges from lab data based on apellido_nombre
    apellido_nombre_merge = pd.merge(judge_names_only, exp_participants, left_on="juez", right_on="participant_apellido_nombre")
    apellido_nombre_merge = apellido_nombre_merge.drop_duplicates(subset=["juez"])
    apellido_nombre_merge.to_excel(dc_interm_path + "/apellido_nombre_merge.xlsx")

    # keeping the judges names from cases that couldn't be merged directly by nombre_apellido and apellido_nombre
    judge_names_only_cleaned = judge_names_only[~judge_names_only["juez"].isin(nombre_apellido_merge["juez"])]
    judge_names_only_cleaned = judge_names_only_cleaned[~judge_names_only_cleaned["juez"].isin(apellido_nombre_merge["juez"])]

    # keeping the judges names from lab that couldn't be merged directly by nombre_apellido and apellido_nombre
    exp_participants_cleaned = exp_participants[~exp_participants["participant_nombre_apellido"].isin(
                                            nombre_apellido_merge["juez"])]
    exp_participants_cleaned = exp_participants_cleaned[~exp_participants_cleaned["participant_apellido_nombre"].isin(
                                            apellido_nombre_merge["juez"])]

    # fuzzy merge for cases with a single judge
    matched_judge_name1 = d6tjoin.top1.MergeTop1(judge_names_only_cleaned, exp_participants_cleaned, fuzzy_left_on=["juez"], 
                            fuzzy_right_on=["participant_apellido_nombre"]).merge()["merged"]
    matched_judge_name1 = matched_judge_name1.rename(columns={"__top1left__": "juez", "__top1right__": "participant_apellido_nombre"})
    matched_judge_name1.to_csv(dc_interm_path + "/matched_judge_name1.csv")
    matched_judge_name2 = d6tjoin.top1.MergeTop1(judge_names_only_cleaned, exp_participants_cleaned, fuzzy_left_on=["juez"], 
                       fuzzy_right_on=["participant_nombre_apellido"]).merge()["merged"]
    matched_judge_name2 = matched_judge_name2.rename(columns={"__top1left__": "juez_2", "__top1right__": "participant_nombre_apellido"})
    matched_judge_name2.to_csv(dc_interm_path + "/matched_judge_name2.csv")

    # fuzzy merge for cases with multiple judges
    mult_matched_judge_name1 = d6tjoin.top1.MergeTop1(multiple_judge_names_1, exp_participants_cleaned, fuzzy_left_on=["juez_1"], 
                               fuzzy_right_on=["participant_apellido_nombre"]).merge()["top1"]["juez_1"]
    mult_matched_judge_name1 = mult_matched_judge_name1.rename(columns={"__top1left__": "juez_1", "__top1right__": "participant_apellido_nombre"})
    mult_matched_judge_name1.to_csv(dc_interm_path + "/mult_matched_judge_name1.csv")
    mult_matched_judge_name2 = d6tjoin.top1.MergeTop1(multiple_judge_names_2, exp_participants_cleaned, fuzzy_left_on=["juez_2"], 
                               fuzzy_right_on=["participant_apellido_nombre"]).merge()["top1"]["juez_2"]
    mult_matched_judge_name2 = mult_matched_judge_name2.rename(columns={"__top1left__": "juez_2", "__top1right__": "participant_apellido_nombre"})
    mult_matched_judge_name2.to_csv(dc_interm_path + "/mult_matched_judge_name2.csv")
    mult_matched_judge_name3 = d6tjoin.top1.MergeTop1(multiple_judge_names_3, exp_participants_cleaned, fuzzy_left_on=["juez_3"], 
                               fuzzy_right_on=["participant_apellido_nombre"]).merge()["top1"]["juez_3"]
    mult_matched_judge_name3 = mult_matched_judge_name3.rename(columns={"__top1left__": "juez_3", "__top1right__": "participant_apellido_nombre"})
    mult_matched_judge_name3.to_csv(dc_interm_path + "/mult_matched_judge_name3.csv")
    mult_matched_judge_name4 = d6tjoin.top1.MergeTop1(multiple_judge_names_4, exp_participants_cleaned, fuzzy_left_on=["juez_4"], 
                               fuzzy_right_on=["participant_apellido_nombre"]).merge()["top1"]["juez_4"]
    mult_matched_judge_name4 = mult_matched_judge_name4.rename(columns={"__top1left__": "juez_4", "__top1right__": "participant_apellido_nombre"})
    mult_matched_judge_name4.to_csv(dc_interm_path + "/mult_matched_judge_name4.csv")
    mult_matched_judge_name5 = d6tjoin.top1.MergeTop1(multiple_judge_names_5, exp_participants_cleaned, fuzzy_left_on=["juez_5"], 
                               fuzzy_right_on=["participant_apellido_nombre"]).merge()["top1"]["juez_5"]
    mult_matched_judge_name5 = mult_matched_judge_name5.rename(columns={"__top1left__": "juez_5", "__top1right__": "participant_apellido_nombre"})
    mult_matched_judge_name5.to_csv(dc_interm_path + "/mult_matched_judge_name5.csv")
    mult_matched_judge_name6 = d6tjoin.top1.MergeTop1(multiple_judge_names_6, exp_participants_cleaned, fuzzy_left_on=["juez_6"], 
                               fuzzy_right_on=["participant_apellido_nombre"]).merge()["top1"]["juez_6"]
    mult_matched_judge_name6 = mult_matched_judge_name6.rename(columns={"__top1left__": "juez_6", "__top1right__": "participant_apellido_nombre"})
    mult_matched_judge_name6.to_csv(dc_interm_path + "/mult_matched_judge_name6.csv")
