class Pic {
    private PImage img;
    private int k;
    public Pic(String filename) 
    {
        img = loadImage(filename + ".png"); //Read and import image data
    }
    public Pic(String filename, int temp) 
    {
        k = temp;
        img = loadImage(filename + k + ".png"); //Read and import image data
    }
    public void Display(float x, float y, float pWidth, float pHeight)
    {
        imageMode(CENTER);
        image(img, x, y, pWidth, pHeight); //Display image
    }
}
