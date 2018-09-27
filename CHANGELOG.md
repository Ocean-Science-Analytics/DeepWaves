# Changelog

## 1.1.1 2018-9-27
Added the ability to accept or reject calls based on score, power, and tonality, in batches.

Added tonality slider, so users can easily adjust tonality.
 - Changed default tonality to 0.3, made amplitude threshold 0 by default
 
The gradient display now only displays the verticle gradient, which better represents how tonality is calculated.
 
Updating the display is now significantly faster, because the data in the existing figures is updated rather than being redrawn.

 
## 1.0.5 2018-9-12
Added a new rat call detection network
 - Trained with the new options in 1.0.4.1
	
SqueakDetect now subtracts the 5th percentile from the spectrogram across the temporal dimension.
 - This increases detection accuracy by filtering out noise bands from low quality microphones.
## 1.0.4.1 2018-9-10
Added option to specify the range for amplitude augmentation

## 1.0.4 - 2018-9-5
Added data augmentation for training new networks 
 - When using "Create Training Images", each image will now be augmented with a random level of white noise, and multiplied by a random gain factor. This substantially increases detection accuracy across different microphones and recording gain.