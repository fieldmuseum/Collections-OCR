# A script to OCR/parse/mangle Collections label-images
# Note - this takes ~2 seconds per label-image
# (c) 2019 The Field Museum - MIT License (https://opensource.org/licenses/MIT)
# https://github.com/fieldmuseum/Collections-OCR

library(tidyr)
library(magick)
library(stringr)
library(tesseract)


# download relevant languages/training data
tesseract_download("lat")  # Latin
tesseract_download("deu")  # German


# get list of JPG & JPEG image files
imagelist <- list.files(path = "images/", pattern = ".jp|.JP")


# setup table for OCRed text
imagesOCR <- data.frame("image" = rep("", NROW(imagelist)),
                        "line_count" = rep("", NROW(imagelist)),
                        "text" = rep("", NROW(imagelist)),
                        stringsAsFactors = F)

imagesOCR$line_count <- as.integer(imagesOCR$line_count)


# loop through each label-image
for (i in 1:NROW(imagelist)) {

  # OCR the image to text
  ocrText <- image_read(paste0("images/", imagelist[i])) %>%
    image_ocr(language = c("eng", "lat", "deu"))
  imagesOCR$text[i] <- ocrText
  
  # include filename & count of lines in row
  imagesOCR$image[i] <- imagelist[i]
  imagesOCR$line_count[i] <- str_count(ocrText, "\n")
  
  # show progress
  print(paste(i, " - ", Sys.time()))

}


# split text lines to separate columns
ocrText <- separate(imagesOCR, text,
                    into = paste0("Line", 
                                  seq(1:max(imagesOCR$line_count, na.rm = T))),
                    # into = seq(1:20),  # if need consistent NCOL
                    sep = "\n",
                    extra = "merge", fill = "right")


# export CSV
write.csv(ocrText, 
          paste0("ocrText-",
                 gsub("\\s+|:", "", Sys.time()),
                 ".csv"),
          na = "",
          row.names = F)