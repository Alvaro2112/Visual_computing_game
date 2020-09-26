PImage img;
PImage check;

boolean done;

void settings() {
  size(1600, 900);
}

void setup() {
  img= loadImage("board1.jpg");
  check = loadImage("board1Scharr_new.bmp");
  done = false;
}

void draw() {
  image(img, 0, 0);

  if (!done) {
    PImage img2 = thresholdHuex(img, 100, 140, 100, 255, 0, 200);
    img2 = thresholdHue(img2, 100, 150, 70, 255, 0, 200);
    img2 = convolute(img2);
    img2 = convolute(img2);
    img2 = threshold(img2,100);
    img2 = scharr(img2);




    image(img2, img.width, 0);
    println(imagesEqual(check, img2));
    done = true;
  }
}

boolean imagesEqual(PImage img1, PImage img2) {
  if (img1.width != img2.width || img1.height != img2.height) {
    return false;
  }
  for (int i = 0; i < img1.width*img1.height; i++) {
    if (red(img1.pixels[i]) != red(img2.pixels[i])) {
      return false;
    }
  }
  //assuming that all the three channels have the same value
  return true;
}

PImage convolute(PImage img) {
  float[][] kernel = { { 9, 12, 9 }, { 12, 15, 12 }, 
    { 9, 12, 9 }};
  float normFactor = 99.f;
  // create a greyscale image (type: ALPHA) for output
  PImage result = createImage(img.width, img.height, ALPHA);

  int N = 3;
  for (int i = 0; i < img.width * img.height; i++) {
    float sum = 0;
    int xi = i % img.width - N/2;
    int yi = i/img.width - N/2;
    if (xi >= 0 && yi >= 0 && xi + N <= img.width && yi + N <= img.height) {
      for (int x = xi; x < xi + N; ++x) {
        for (int y = yi; y < yi + N; ++y) {
         
          sum += kernel[x - xi][y - yi] * brightnessOfIndexed(img, x, y);
        }
      }
      sum /= normFactor;
      result.pixels[i] = color(sum);
    } else {
      result.pixels[i] = color(0);
    }
  }
  
  return result;
}

float brightnessOfIndexed(PImage img, int x, int y) {
  return brightness(img.pixels[x + y*img.width]);
}

PImage scharr(PImage img) {
  float[][] vKernel = {
    { 3, 0, -3 }, 
    { 10, 0, -10 }, 
    { 3, 0, -3 }};
  float[][] hKernel = {
    { 3, 10, 3}, 
    { 0, 0, 0}, 
    { -3, -10, -3 } };
  PImage result = createImage(img.width, img.height, ALPHA);
  // clear the image
  for (int i = 0; i < img.width * img.height; i++) {
    result.pixels[i] = color(0);
  }
  float max=0;
  float[] buffer = new float[img.width * img.height];

  int N = 3;
  for (int i = 0; i < img.width * img.height; i++) {
    float sum_h = 0;
    float sum_v = 0;
    float sum = 0;
    int xi = i % img.width - N/2;
    int yi = i/img.width - N/2;
    if (xi >= 0 && yi >= 0 && xi + N <= img.width && yi + N <= img.height) {
      for (int x = xi; x < xi + N; ++x) {
        for (int y = yi; y < yi + N; ++y) {
        
          sum_h += hKernel[x - xi][y - yi] * brightnessOfIndexed(img, x, y);
          sum_v += vKernel[x - xi][y - yi] * brightnessOfIndexed(img, x, y);
        }
      }
      sum = sqrt(pow(sum_h, 2) + pow(sum_v, 2));
      buffer[i] = sum;
      if (sum > max) {
        max = sum;
      }
    } else {
     // buffer[i] = 0;
    }
  }

  for (int y = 1; y < img.height - 1; y++) { // Skip top and bottom edges 
    for (int x = 1; x < img.width - 1; x++) { // Skip left and right
      int val=(int) ((buffer[y * img.width + x] / max)*255);
      result.pixels[y * img.width + x]=color(val);
    }
  }
  return result;
}



PImage threshold(PImage img, int threshold) {
  // create a new, initially transparent, 'result' image
  PImage result = createImage(img.width, img.height, RGB);
  for (int i = 0; i < img.width * img.height; i++) {
    if (brightness(img.pixels[i]) < threshold)
      result.pixels[i] = color(0);
    else
      result.pixels[i] = color(255);
  }
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
PImage thresholdHuex(PImage img, int minHue, int maxHue, int minSat, int maxSat, int minBright, int maxBright) {
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
