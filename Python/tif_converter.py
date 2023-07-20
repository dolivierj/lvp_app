from PIL import Image
import os
from tqdm import tqdm
import pandas as pd

def convert_format(img_file, out_name, out_format, max_size = None):
    try : 
        img = Image.open(img_file)
    except :
        return
    if max_size :
        max_origin = max(img.size)
        if max_origin > max_size:
            ratio = max_size / max_origin
            new_size = tuple([round(i*ratio) for i in img.size])
            img = img.resize(new_size)
    img.save(out_name, format=out_format)


def pad_image(img, max_width, max_height):
    width, height = img.size

    # Create a square canvas of max_size
    new_img = Image.new("RGB", (max_width, max_height))

    # Calculate top and left padding
    top_padding = (max_height - height) // 2
    left_padding = (max_width - width) // 2

    # Paste the original image into the centered of the new_img
    new_img.paste(img, (left_padding, top_padding))
    return new_img

def convert_to_tif(images, output):
    """
    Convert a list of images to a single TIF file.
    
    :param images: list of image filenames
    :param output: output TIF filename
    """

    # Open images
    img_list = [Image.open(img) for img in images]
    
    max_width = list()
    max_height = list()
    for img in img_list:
        img_size = img.size
        max_width.append(img_size[0])
        max_height.append(img_size[1])
    max_width = max(max_width)
    max_height = max(max_height)
    
    img_list = [pad_image(img, max_width, max_height) for img in img_list]

    # Save the images to a single TIF file
    img_list[0].save(output, "TIFF", compression="tiff_deflate", save_all=True, append_images=img_list[1:])


def get_image_files(directory):
    image_files = []
    for file in os.listdir(directory):
        if file.endswith(".jpg") or file.endswith(".png") or file.endswith(".webp") or file.endswith(".jfif") :
            image_files.append(os.path.join(directory, file))
    return image_files

def get_tif_files(directory):
    image_files = []
    for file in os.listdir(directory):
        if file.endswith(".tif") :
            image_files.append(os.path.join(directory, file))
    return image_files

def db_to_tif(path, rm_old):
    print("Converting to TIF")
    dirs = os.listdir(path)
    
    for i in tqdm(dirs) :
        i_path = os.path.join(path, i)
        images = get_image_files(i_path)
        output = f"{i_path}/{i}.tif"
        convert_to_tif(images, output)
        if rm_old :
            for file in images:
                os.remove(file)

def remove_tif(path):
    print("Removing TIF files")
    dirs = os.listdir(path)
    for i in tqdm(dirs) :
        i_path = os.path.join(path, i)
        images = get_tif_files(i_path)
        for file in images:
            os.remove(file)
            
def db_to_webp(path, max_size = None):
    print("Converting to webp")
    dirs = os.listdir(path)
    for i in tqdm(dirs):
        i_path = os.path.join(path, i)
        source_dir = os.path.join(i_path, 'source')       
        images = get_image_files(source_dir)
        for j in images:
            convert_format(img_file = j,
                           out_name = os.path.join(i_path, os.path.split(j)[-1].split('.')[0] + '.webp'),
                           out_format = 'webp',
                           max_size = max_size
                           )

def db_to_inspector(path, out_format, max_size = None):
    print(f"Converting to {out_format}")
    dirs = os.listdir(path)
    for i in tqdm(dirs):
        i_path = os.path.join(path, i)
        source_dir = os.path.join(i_path, 'source')       
        inspector_dir = os.path.join(i_path, 'inspector')
        if not os.path.isdir(inspector_dir):
            os.mkdir(inspector_dir)
        images = get_image_files(source_dir)
        for j in images:
            convert_format(img_file = j,
                           out_name = os.path.join(inspector_dir, os.path.split(j)[-1].split('.')[0] + '.' + out_format),
                           out_format = out_format,
                           max_size = max_size
                           )

def inspector_cleanup(path):
    print('Cleaning up inspector images')
    dirs = os.listdir(path)
    for i in tqdm(dirs):
        inspector_path = os.path.join(path, i, 'inspector')
        images = get_image_files(inspector_path)
        for j in images:
            os.remove(j)

def db_cleanup(path):
    print('Cleaning up database')
    dirs = os.listdir(path)
    for i in tqdm(dirs):
        i_path = os.path.join(path, i)
        images = get_image_files(i_path)
        for j in images:
            os.remove(j)

def move_to_source(path):
    print("Moving images to source dir")
    dirs = os.listdir(path)
    for i in tqdm(dirs):        
        i_path = os.path.join(path, i)
        source_dir = os.path.join(i_path, 'source')
        if not os.path.isdir(source_dir):
            os.mkdir(source_dir)
        images = get_image_files(i_path)
        for j in images:
            os.rename(j, os.path.join(source_dir, os.path.split(j)[-1]))    

def move_from_source(path):
    print("Moving images out of source dir")
    dirs = os.listdir(path)
    for i in tqdm(dirs):
        i_path = os.path.join(path, i)
        source_dir = os.path.join(i_path, 'source')
        if not os.path.isdir(source_dir):
            continue
        images = get_image_files(source_dir)
        for j in images:
            os.rename(j, os.path.join(i_path, os.path.split(j)[-1]))    
            

def initialise_database(path, items_folder, out_name = 'database.csv'):
    item_list = os.listdir(os.path.join(path, items_folder))
    out_path = os.path.join(path, out_name)
    db_table = pd.DataFrame()
    db_table['Name'] = item_list
    db_table.to_csv(out_path, index_label= 'Index')
    

path = "D:/Dropbox/2_WDB/apps/lvp_app/rshiny/database/"
items_folder = 'items'

# db_cleanup(path = os.path.join(path, items_folder))

move_to_source(path = path)
db_to_webp(path = os.path.join(path, items_folder), max_size = 800)
db_to_inspector(path = os.path.join(path, items_folder), out_format = 'jpeg', max_size = None)
# inspector_cleanup(path = os.path.join(path, items_folder))
