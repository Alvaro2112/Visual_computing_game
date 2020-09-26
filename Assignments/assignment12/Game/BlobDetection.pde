import java.util.ArrayList;
import java.util.List;
import java.util.TreeSet;


class BlobDetection {
  PImage findConnectedComponents(PImage input, boolean onlyBiggest) {

    PImage img = input;

    // First pass: label the pixels and store labels' equivalences
    int [] labels= new int [img.width * img.height];
    List<TreeSet<Integer>> labelsEquivalences= new ArrayList<TreeSet<Integer>>();

    int currentLabel = 1;

    TreeSet<Integer> neighbours = new TreeSet<Integer>();


    for (int y_axis = 0; y_axis <  img.height; y_axis++) {//loop through image
      for (int x_axis = 0; x_axis < img.width; x_axis++) {

        if (brightness(img.pixels[y_axis * img.width + x_axis]) == 255) { //check if white

          neighbours.clear();

          // Check 4 pixels (possible neighbours)
          if (boolean(y_axis)) {
            int pos = (y_axis - 1) * img.width + x_axis;
            if (labels[pos] != 0) {
              neighbours.add(labels[pos]);
            }
          }

          if (boolean(x_axis)) {
            int pos = y_axis * img.width + x_axis - 1;
            if (labels[pos] != 0) {
              neighbours.add(labels[pos]);
            }
          }

          if (boolean(x_axis) && boolean(y_axis)) {
            int pos = (y_axis-1) * img.width + x_axis - 1;
            if (labels[pos] != 0) {
              neighbours.add(labels[pos]);
            }
          }

          if (boolean(y_axis) && x_axis < img.width - 2) {
            int pos = (y_axis - 1) * img.width + x_axis + 1;
            if (labels[pos] != 0) {
              neighbours.add(labels[pos]);
            }
          }

          int pos = x_axis + y_axis * img.width;

          if (neighbours.isEmpty()) {

            TreeSet<Integer> new_label  = new TreeSet<Integer>();
            new_label.add(currentLabel); //convert to set
            labelsEquivalences.add(new_label); //create new entry in labelsEquivalences
            labels[pos] = currentLabel;
            currentLabel += 1;
            
          } else {

            if (neighbours.size()>1) {
              
              TreeSet<Integer> new_neighbours = new TreeSet<Integer>();

              for (Integer n : neighbours) {
                new_neighbours.addAll(labelsEquivalences.get(n-1));
              }
              for (Integer n : neighbours) {
                labelsEquivalences.set(n-1, new_neighbours);
              }
            }

            labels[x_axis + y_axis * img.width] = neighbours.first();
          }
        }
      }
    }
    // Second pass: re-label the pixels by their equivalent class
    // if onlyBiggest==true, count the number of pixels for each label

    int [] count= new int [currentLabel - 1];

    for (int i = 0; i < input.height * input.width; i++) {
      if ( labels[i]==255) {
        
        labels[i] =labelsEquivalences.get(labels[i]-1).first();
        
        if (onlyBiggest) {
          count[labels[i] - 1] += 1;
        }
        
      }
    }


    // Finally:
    // if onlyBiggest==false, output an image with each blob colored in one uniform color
    // if onlyBiggest==true, output an image with the biggest blob in white and others in black


    int[] pixels_rgb = new int[count.length];


    if (onlyBiggest) {
      int max = -1;
      for (int i=0; i < count.length; i++) {
        max = max(max, count[i]);
      }
      for (int i=0; i < count.length; i++) {
        pixels_rgb[i] = count[i] == max ? color(255) : color(0);
      }
    } else {

     for (TreeSet<Integer> labelss : labelsEquivalences) {
        int random_color = color(random(100, 255), random(100, 255), random(100, 255));// get new random color for different blob
        for (Integer i : labelss) {
          pixels_rgb[i-1] = random_color;
        }
      }
    }


    for (int i=0; i < img.width * img.height; i++) { //loop through pixels
      if (labels[i] != 0) { // check that pixel belongs to a blob
        img.pixels[i] = pixels_rgb[labels[i] -1]; //assign colors
      }
    }
    return img;
  }
}
