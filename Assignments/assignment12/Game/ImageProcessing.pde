
import java.util.Collections;
import gab.opencv.*;
import processing.video.*;

class ImageProcessing extends PApplet {
  //Capture cam;
  Movie cam;

  BlobDetection blobs;
  QuadGraph corners;
  TwoDThreeD twoDthreeD;
  OpenCV opencv;
  HoughTransform houghT;

  boolean done;

  final int NUMBER_LINES_HOUGH= 5;
  final boolean VERBOSE_QUAD = false;
  final int RADIUS_CIRCLE_CORNERS = 15;

  final int MAX_COLOR = 255;
  final int MIN_COLOR = 0;

  PVector rotations;
  void settings() {
    size(800, 500);//TODO
  }

  void setup() {
    /* IMAGE PROCESSING TOOLS */
    //img= loadImage( "C:/Users/alvar/Desktop/push/projet_visual_computing/Assignments/assignment12/Game/board1.jpg");

    corners = new QuadGraph();
    blobs = new BlobDetection();
    opencv = new OpenCV(this, 100, 100);
    rotations = new PVector(0, 0, 0);
    houghT = new HoughTransform();
    cam = new Movie(this, PATH_TO_VIDEO);
    cam.loop();
    cam.speed(0.1);
    twoDthreeD = new TwoDThreeD(cam.width, cam.height, 0);
  }

  public PVector getRotation() {
    return rotations;
  }

  void draw() {

    if (cam.available() ==true) {
      cam.read();
    }
    img = cam.get();
    image(img, 0, 0);

    PImage quads = thresholdHue(img, 50, 138, 50, MAX_COLOR, 0, 250);
    //quads = gaussianBlur(quads);
    //quads = threshold(quads, 100); 
    quads = blobs.findConnectedComponents(quads, false);
    quads = scharrEdgeDetection(quads);
    List<PVector> quadss = houghT.hough(quads, 5);
    houghT.plotTheLines(quads, quadss);
    List<PVector> corner_list = corners.findBestQuad(quadss, img.width, img.height, (img.width * img.height), 0, false);
    //if(corner_list.size() != 4)
    //  println("Empty");
    for (PVector angle : corner_list) {
      fill(MIN_COLOR);
      circle(angle.x, angle.y, RADIUS_CIRCLE_CORNERS);
    }


    /** FROM 2D TO 3D **/
    List<PVector> homogeneousCorners = new ArrayList<PVector>();
    for (PVector v : corner_list) {
      homogeneousCorners.add(v.set(v.x, v.y, 1));
    }

    if (homogeneousCorners.size() == 4) { //Change old rotation only if has a whole quad
      rotations = twoDthreeD.get3DRotations(homogeneousCorners);
      //println(rotations);
      rotations = new PVector(rotations.x > PI/2 ? rotations.x - PI : (rotations.x < -PI/2 ? rotations.x + PI : rotations.x), 
        rotations.y > PI/2 ? rotations.y - PI : (rotations.y < -PI/2 ? rotations.y + PI : rotations.y), 
        1);
    }
  }

  /* IMAGE COMPARISON */
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

  /* IMAGE PROCESSING TOOLS */
  float brightnessOfIndexed(PImage img, int x, int y) {
    return brightness(img.pixels[x + y*img.width]);
  }

  PImage convolute(PImage img) {
    float[][] kernel = {{ 9, 12, 9 }, 
      { 12, 15, 12 }, 
      { 9, 12, 9 }};

    float normFactor = 99.f;
    PImage result = createImage(img.width, img.height, ALPHA);
    result.loadPixels();
    int N = 3;
    float acc;

    for (int x = 1; x < img.width-1; ++x) {
      for (int y = 1; y < img.height-1; ++y) {
        acc = 0;
        for (int i =0; i<N; ++i) {
          for (int j=0; j<N; ++j) {
            acc+= kernel[i][j]*brightness(img.pixels[x - N/2 + i + img.width * (y - N/2 + j)]);
          }
        }
        float change = (int)((float)acc/normFactor);
        result.pixels[y * img.width + x] = color(change);
      }
    }
    for (int x = 0; x < img.width; x++) {
      result.pixels[x] = color(0);
      result.pixels[x + (img.height - 1) *img.width] = color(0);
    }

    for (int y = 0; y < img.height; y++) {
      result.pixels[y * img.width] = color(0);
      result.pixels[img.width - 1 + y*img.width] = color(0);
    }

    result.updatePixels();
    return result;
  }


  PImage gaussianBlur(PImage img) {
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
        result.pixels[i] = color(MIN_COLOR);
      }
    }

    return result;
  }


  PImage scharrEdgeDetection(PImage img) {
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
      }
    }

    for (int y = 1; y < img.height - 1; y++) { // Skip top and bottom edges 
      for (int x = 1; x < img.width - 1; x++) { // Skip left and right
        int val=(int) ((buffer[y * img.width + x] / max)*MAX_COLOR);
        result.pixels[y * img.width + x]=color(val);
      }
    }
    return result;
  }

  public class HoughTransform {
    public List<PVector> hough(PImage edgeImg, int nLines) {
      float discretizationStepsPhi= 0.06f; 
      float discretizationStepsR= 1.75f; 
      int minVotes=125;

      // dimensions of the accumulator
      int phiDim= (int) (Math.PI / discretizationStepsPhi+1);

      //The max radius is the image diagonal, but it can be also negative
      int rDim= (int) ((sqrt(edgeImg.width*edgeImg.width+edgeImg.height*edgeImg.height) * 2) / discretizationStepsR+1);

      // our accumulator
      int[] accumulator=new int[phiDim* rDim];

      // pre-compute the sin and cos values
      float[] tabSin = new float[phiDim];
      float[] tabCos = new float[phiDim];
      float ang = 0;
      float inverseR = 1.f / discretizationStepsR;
      for (int accPhi = 0; accPhi < phiDim; ang += discretizationStepsPhi, accPhi++) {
        // we can also pre-multiply by (1/discretizationStepsR) since we need it in the Hough loop
        tabSin[accPhi] = (float) (Math.sin(ang) * inverseR);
        tabCos[accPhi] = (float) (Math.cos(ang) * inverseR);
      }


      // Fill the accumulator: on edge points (ie, white pixels of the edge
      // image), store all possible (r, phi) pairs describing lines going
      // through the point.
      for (int y = 0; y < edgeImg.height; y++) {
        for (int x = 0; x < edgeImg.width; x++) {
          // Are we on an edge?
          if (brightness(edgeImg.pixels[y * edgeImg.width+ x]) != 0) {

            // ...determine here all the lines (r, phi) passing through
            // pixel (x,y), convert (r,phi) to coordinates in the
            // accumulator, and increment accordingly the accumulator.
            // Be careful: r may be negative, so you may want to center onto
            // the accumulator: r += rDim / 2

            for (int i = 0; i < phiDim; i ++) {
              double r = x * tabCos[i] + y * tabSin[i];
              r += rDim / 2;
              accumulator[(int)(i*rDim+r)] += 1;
            }
          }
        }
      }

      ArrayList<Integer> bestCandidates = new ArrayList<Integer>();

      int region_dim = 10;

      for (int i = 0; i < accumulator.length; i++) {
        if (accumulator[i] > minVotes) {
          boolean is_best = true;
          for (int j = 0; j < 2 * region_dim; j++) {
            if ((j - region_dim + i >= 0) && (j - region_dim + i < accumulator.length) &&  (j - region_dim + i != 1)) {
              if (accumulator[j- region_dim + i] > accumulator[i]) {
                is_best = false;
                break;
              }
            }
          }
          if (is_best) {
            bestCandidates.add(i);
          }
        }
      }

      Collections.sort(bestCandidates, new HoughComparator(accumulator));


      PImage houghImg = createImage(rDim, phiDim, ALPHA);
      for (int i = 0; i < accumulator.length; i++) {
        houghImg.pixels[i] = color(min(255, accumulator[i]));
      }

      houghImg.resize(400, 400); 
      houghImg.updatePixels();

      ArrayList<PVector> lines = new ArrayList<PVector>();

      for (int idx= 0; idx < Math.min(bestCandidates.size(), nLines); idx++) {
        int i = bestCandidates.get(idx);
        int accPhi= (int) (i / (rDim));
        int accR= i- (accPhi) * (rDim);
        float r = (accR- (rDim) * 0.5f) * discretizationStepsR;
        float phi = accPhi* discretizationStepsPhi;
        lines.add(new PVector(r, phi));
      }

      return lines;
    }

    public void plotTheLines(PImage edgeImg, List<PVector> lines) {
      for (int idx = 0; idx< lines.size(); idx++) {
        PVector line = lines.get(idx);
        float r = line.x; 
        float phi = line.y;
        // Cartesian equation of a line: y = ax + b
        // in polar, y = (-cos(phi)/sin(phi))x + (r/sin(phi))
        // => y = 0 : x = r / cos(phi)
        // => x = 0 : y = r / sin(phi)

        // compute the intersection of this line with the 4 borders of
        // the image
        int x0 = 0;
        int y0 = (int) (r / sin(phi));
        int x1 = (int) (r / cos(phi));
        int y1 = 0;
        int x2 = edgeImg.width;
        int y2 = (int) (-cos(phi) / sin(phi) * x2 + r / sin(phi));
        int y3 = edgeImg.width;
        int x3 = (int) (-(y3 - r / sin(phi)) * (sin(phi) / cos(phi)));

        // Finally, plot the lines
        stroke(204, 102, 0);
        if (y0 > 0) {
          if (x1 > 0)
            line(x0, y0, x1, y1);
          else if (y2 > 0)
            line(x0, y0, x2, y2);
          else
            line(x0, y0, x3, y3);
        } else {
          if (x1 > 0) {
            if (y2 > 0)
              line(x1, y1, x2, y2);
            else
              line(x1, y1, x3, y3);
          } else
            line(x2, y2, x3, y3);
        }
      }
    }
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
