# A script to use Google Cloud Vision to OCR/parse/mangle Collections label-images
# Note!
#   - this may take a few seconds per label-image
#   - running >1000 API calls/month incurs a fee
# (c) 2019 The Field Museum - MIT License (https://opensource.org/licenses/MIT)
# https://github.com/fieldmuseum/Collections-OCR

library(googleCloudVisionR)  # NOTE - requires API Key / Service Account
library(tidyr)
library(readr)
library(stringr)
library(magick)

# get list of local JPG & JPEG image files [REVERT]
imagelist <- list.files(path = "images/", pattern = ".jp|.JP")
imagenames <- gsub(".jp.*|.JP.*", "", imagelist)


# # Prompt user for input/output batch directory names?
# image_dir <- readline("Paste the path for the image directory: ")


# Retrieve OCR text ####

# Setup table for OCRed text
imagesOCR <- data.frame("image" = rep("", NROW(textlist)),
                        "line_count" = rep("", NROW(textlist)),
                        "text" = rep("", NROW(textlist)),
                        stringsAsFactors = F)

imagesOCR$line_count <- as.integer(imagesOCR$line_count)


# setup output dir
# # add image_dir if use prompt above
if (!dir.exists("ocr_text")) {  # paste0(image_dir, "_out")
  dir.create("ocr_text")  # paste0(image_dir, "_out")
} else {
  print("output directory exists")
}


# Loop through each label-image
for (i in 1:NROW(imagelist)) {
  
  # # If files are over 20MB, uncomment this to lower quality + avoid error?
  # ### NOTE! This will overwrite image with lower-quality file.
  # 
  # if (file.info(paste0("images/", imagelist[i]))$size > 20000000) {
  #   image_write(image_read(paste0("images/", imagelist[i])),
  #               path = paste0("images/", imagelist[i]),
  #               quality = 80)

  # OCR image
  # CHECK/FIX THIS FXN ####
  ocr_list <- gcv_get_image_annotations(imagePaths = paste0("images/", imagelist[i]),
                                        feature = "DOCUMENT_TEXT_DETECTION",
                                        savePath = paste0("ocr_text/", 
                                                          imagenames[i], "_text.csv"))
  
  # Add raw text to dataframe
  imagesOCR$text[i] <- read_file(ocr_list$local_path)  # CHECK/FIX THIS PATH ####
  
  # Add filename & count of lines in row
  imagesOCR$image[i] <- imagelist[i]
  imagesOCR$line_count[i] <- str_count(ocr_list$local_path, "\n+")
  
  # show progress
  print(paste(i, " - ", Sys.time()))
  
  # rate limit to max of 240/min (Vision API limit = 1800/min)
  Sys.sleep(0.25)
 
}


# split text lines to separate columns
ocrText <- separate(imagesOCR, text,
                    into = paste0("Line", 
                                  seq(1:max(imagesOCR$line_count, na.rm = T))),
                    # into = seq(1:20),  # if need consistent NCOL
                    sep = "(\n)+",
                    extra = "merge", fill = "right")


# export CSV
write.csv(ocrText, 
          paste0("ocrText-",
                 gsub("\\s+|:", "", Sys.time()),
                 # image_dir,
                 ".csv"),
          na = "",
          row.names = F)