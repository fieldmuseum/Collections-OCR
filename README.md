# Collections-OCR
A script to batch collections label-images through OCR

Dependencies - make sure to install these libraries first:
- `magick` - to read in image files
- `tesseract` - to do OCR magic 
- `stringr` - to split the OCR'ed lines to columns

Notes:
- this takes ~2 seconds per label-image
- this currently uses Tesseract's English ("eng"), German ("deu") and Latin ("lat") libraries. 


To run the script:
1. Add a folder named "images" to this script's directory
2. Add the images (JPG & JPEG) you'd like to OCR to that directory
3. Run the script (`Rscript ocrMangle.R`)

Output - a CSV named "ocrText-[Date-time].csv", containing these columns:
- "image" = filename for each JPG and JPEG
- "line_count" = number of lines in each OCR transcription
- "Line1" - "Line[N]" = text for each line in the OCR transcription.
  - the number of "Line" columns will match the maximum number of lines as needed.

