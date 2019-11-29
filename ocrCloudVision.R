# A script to use Google Cloud Vision to OCR/parse/mangle Collections label-images
# Note!
#   - this may take >30 seconds per label-image
#   - running >1000 API calls/month incurs a fee
# (c) 2019 The Field Museum - MIT License (https://opensource.org/licenses/MIT)
# https://github.com/fieldmuseum/Collections-OCR

library(googleCloudVisionR)  # NOTE - requires API Key / Service Account
library(tidyr)
library(readr)
library(stringr)
# library(magick)

# get list of local JPG & JPEG image files [REVERT]
imagelist <- list.files(path = "images/", pattern = ".jp|.JP")
imagenames <- gsub(".jp.*|.JP.*", "", imagelist)


# # Prompt user for input/output batch directory names?
# image_dir <- readline("Paste the path for the image directory: ")


# Retrieve OCR text ####

# Setup table for OCRed text
imagesOCR <- data.frame("image" = rep("", NROW(imagelist)),
                        "imagesize_MB" = rep("", NROW(imagelist)),
                        "ocr_start" = rep("", NROW(imagelist)),
                        "ocr_duration" = rep("", NROW(imagelist)),
                        "line_count" = rep("", NROW(imagelist)),
                        "text" = rep("", NROW(imagelist)),
                        stringsAsFactors = F)

imagesOCR$line_count <- as.integer(imagesOCR$line_count)


# setup output dir
# # add image_dir if use prompt above
if (!dir.exists("ocr_text")) {  # paste0(image_dir, "_out")
  dir.create("ocr_text")  # paste0(image_dir, "_out")
  print("output directory created")
} else {
  print("output directory already exists")
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
  # ### NOTE! This can take over ~30s per image
  print(paste(i, "- starting OCR -", Sys.time()))
  
  imagesOCR$ocr_start[i] <- as.character(Sys.time())
  start <- Sys.time()
  
  ocr_list <- gcv_get_image_annotations(imagePaths = paste0("images/", imagelist[i]),
                                        feature = "DOCUMENT_TEXT_DETECTION") #,
                                        # savePath = paste0("ocr_text/", 
                                        #                   imagenames[i], "_text.csv"))
  
  print(paste(i, "- finishing OCR -", Sys.time()))
  end <- Sys.time()
  
  # Add raw text to dataframe
  imagesOCR$text[i] <- ocr_list$description
  
  # Add OCR duration (in seconds), & text-lines per image, filename, filesize (in MB)
  imagesOCR$ocr_duration[i] <- as.integer(end) - as.integer(start)
  imagesOCR$line_count[i] <- str_count(ocr_list$description, "\n+")
  imagesOCR$image[i] <- imagelist[i]
  imagesOCR$imagesize_MB[i] <- round(file.info(paste0("images/",
                                                      imagelist[i]))$size
                                     / 1000000, 2)
  
  # show progress
  print(paste(i, "- done -", Sys.time()))
  
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