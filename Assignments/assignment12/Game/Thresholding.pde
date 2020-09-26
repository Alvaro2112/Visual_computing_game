final class Thresholding {

  PImage threshold(PImage img, int threshold) {
    // create a new, initially transparent, 'result' image
    PImage result = createImage(img.width, img.height, RGB);
    for (int i = 0; i < img.width * img.height; i++) {
      if (brightness(img.pixels[i]) < threshold)
        result.pixels[i] = color(0);
      else
        result.pixels[i] = color(255);
    }
    result.updatePixels();
    return result;
  }

  PImage thresholdHue(PImage img, int minHue, int maxHue, int minSat, int maxSat, int minBright, int maxBright) {
    // create a new, initially transparent, 'result' image
    PImage result= createImage(img.width, img.height, RGB);
    for (int i = 0; i < img.width* img.height; i++) {
      if (hue(img.pixels[i]) >= minHue && hue(img.pixels[i]) <= maxHue && saturation(img.pixels[i]) >= minSat && saturation(img.pixels[i]) <= maxSat && brightness(img.pixels[i]) >= minBright && brightness(img.pixels[i]) <= maxBright) {
        result.pixels[i] = color(255);
      }
    }
    result.updatePixels();
    return result;
  }

  PImage thresholdHueWithOriginalColor(PImage img, int minHue, int maxHue, int minSat, int maxSat, int minBright, int maxBright) {
    // create a new, initially transparent, 'result' image
    PImage result= createImage(img.width, img.height, RGB);
    for (int i = 0; i < img.width* img.height; i++) {
      if (hue(img.pixels[i]) >= minHue && hue(img.pixels[i]) <= maxHue && saturation(img.pixels[i]) >= minSat && saturation(img.pixels[i]) <= maxSat && brightness(img.pixels[i]) >= minBright && brightness(img.pixels[i]) <= maxBright) {
        result.pixels[i] = color(img.pixels[i]);
      }
    }
    result.updatePixels();
    return result;
  }
}
