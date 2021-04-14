class Pic {
    PImage img;
    int k;
    Pic(String filename) 
    {
        img = loadImage(filename + ".png"); //Read and import image data
    }
    Pic(String filename, int temp) 
    {
        k = temp;
        img = loadImage(filename + k + ".png"); //Read and import image data
    }
    void display(float x, float y, float pWidth, float pHeight)
    {
        imageMode(CENTER);
        image(img, x, y, pWidth, pHeight); //Display image
    }
}
