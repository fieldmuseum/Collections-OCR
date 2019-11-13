# A script to use Google apps to OCR/parse/mangle Collections label-images
# Note - this may take a few seconds per label-image
# (c) 2019 The Field Museum - MIT License (https://opensource.org/licenses/MIT)
# https://github.com/fieldmuseum/Collections-OCR

library(googledrive)
library(tidyr)
library(readr)
library(stringr)


# get list of local JPG & JPEG image files [REVERT]
imagelist <- list.files(path = "images/", pattern = ".jp|.JP")
imagenames <- gsub(".jp.*|.JP.*", "", imagelist)


# NOTE - update path to appropriate google folder
googleFolder <- "https://drive.google.com/drive/folders/1fOI5JC1naQtfBZ2mXlWFlBOq2bKN17KA"
# googleFolder <- readline("Paste the URL to a googledrive here: ")


# Upload & OCR ####

# Loop through each label-image
for (i in 1:NROW(imagelist)) {
  
  # Setup Google Doc for image
  drive_upload(media = paste0("images/", imagelist[i]),
               path = as_id(googleFolder),
               name = paste0(imagenames[i], "_text"), 
               type = "document",
               overwrite = FALSE)
  
  print(paste(i, " - ", Sys.time()))
  
}


# get list of OCR text files
filelist <- drive_ls(path = as_id(googleFolder),
                     recursive = FALSE)

textlist <- filelist[grepl("_text", filelist$name)==TRUE,]


# Retrieve OCR text ####

# Setup table for OCRed text
imagesOCR <- data.frame("image" = rep("", NROW(textlist)),
                        "line_count" = rep("", NROW(textlist)),
                        "text" = rep("", NROW(textlist)),
                        stringsAsFactors = F)

imagesOCR$line_count <- as.integer(imagesOCR$line_count)

if (!dir.exists("ocr_text")) {
  dir.create("ocr_text")
} else {
  print("'ocr_text' directory exists")
}

# Download the OCR'ed label-images
for (i in 1:NROW(textlist)) {
  
  # Setup Google Doc for image
  dllist <- drive_download(file = as_id(textlist$id[i]),
                           path = paste0("ocr_text/", textlist$name),
                           type = "txt",
                           overwrite = FALSE)
  
  # OCR the image to text
  imagesOCR$text[i] <- read_file(dllist$local_path)
  
  # include filename & count of lines in row
  imagesOCR$image[i] <- imagelist[i]
  imagesOCR$line_count[i] <- str_count(ocrText, "\n+")
  
  # show progress
  print(paste(i, " - ", Sys.time()))
  
}


# # loop through each label-image
# for (i in 1:NROW(imagelist)) {
# 
#   # # Setup Google Doc for image
#   # drive_put(media = "images/PE78981_label.jpg",
#   #           path = as_id("https://drive.google.com/drive/folders/1fOI5JC1naQtfBZ2mXlWFlBOq2bKN17KA"),
#   #           name = "test_text", 
#   #           type = "document")
#   
#   # OCR the image to text
#   ocrText <- image_read(paste0("images/", imagelist[i])) %>%
#     image_ocr(language = c("eng", "lat", "deu"))
#   imagesOCR$text[i] <- ocrText
#   
#   # include filename & count of lines in row
#   imagesOCR$image[i] <- imagelist[i]
#   imagesOCR$line_count[i] <- str_count(ocrText, "\n+")
#   
#   # show progress
#   print(paste(i, " - ", Sys.time()))
#   
# }


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
                 ".csv"),
          na = "",
          row.names = F)