# Collections-OCR
A few scripts that batches of collections label-images through OCR

## Google Cloud Vision API & `ocrCloudVision.R`
### Dependencies 
Make sure to install these libraries first:
- `googleCloudVisionR` - to do OCR magic 
- Other dependencies include `readr`, `tidyr`, `stringr` for data handling

### How to run `ocrCloudVision.R`:
Notes:
- This currently uses Google's Cloud Vision API, which requires:
  - Being aware of [pricing & quotas for the Google Vision API](https://cloud.google.com/vision/pricing)
  - Setting up a project on Google Cloud Platform
  - Authenticating your magine by setting up a Service account & key 
    - Get help from the [cloudyr repo for `googleCloudVisionR`](https://cloudyr.github.io/googleCloudVisionR/)
- This can takes over 30 seconds per label-image.
  - Be mindful how many images you add to your "images" directory.
  - Be mindful of your internet connection speed
  - Keep image sizes under 20MB
    (Overall, smaller image files transfer and process more quickly)
- Output likely needs some [or many] follow-up/clean-up steps.
  - Batch similar images together to streamline follow-up steps.

To run the script:
1. Add a folder named "images" to this script's directory
2. Add the images (JPG & JPEG) you'd like to OCR to that directory
3. Run the script (`Rscript ocrCloudVision.R`)

### Output from `ocrCloudVision.R`:
A CSV named "ocrText-[Date-time].csv", containing these columns:
- **"image"** = filename for each JPG and JPEG
- **"imagesize"** = filesize for each image (in MB)
- **"ocr_start"** = start-date and time when an image was submitted to the Google Vision API
- **"ocr_duration"** = duration (in seconds) of the OCR process
- **"line_count"** = number of lines in each OCR transcription
- **"Line1" - "Line[N]"** = text for each line in the OCR transcription of an image.
  - the number of **"Line"** columns will match the maximum number of lines as needed.


## Tesseract & `ocrMangle.R`
### Dependencies 
Make sure to install these libraries first:
- `magick` - to read in image files
- `tesseract` - to do OCR magic 
- `stringr` - to split the OCR'ed lines to columns

### How to run `ocrMangle.R`:
Notes:
- This can takes over 10 seconds per label-image.
  - Be mindful how many images you add to your "images" directory.
- This currently uses Tesseract's English ("eng"), German ("deu"), and Latin ("lat") libraries. 
- Output likely needs some [or many] follow-up/clean-up steps.
  - Batch similar images together to streamline follow-up steps.

To run the script:
1. Add a folder named "images" to this script's directory
2. Add the images (JPG & JPEG) you'd like to OCR to that directory
3. Run the script (`Rscript ocrMangle.R`)

### Output from `ocrMangle.R`:
A CSV named "ocrText-[Date-time].csv", containing these columns:
- **"image"** = filename for each JPG and JPEG
- **"line_count"** = number of lines in each OCR transcription
- **"Line1" - "Line[N]"** = text for each line in the OCR transcription.
  - the number of **"Line"** columns will match the maximum number of lines as needed.


## Google Drive API & `ocrGoogleDrive.R`
### This is drafty; might work for small batches, but needs work.
