import processing.pdf.*;
import static javax.swing.JOptionPane.*;

PImage img;

int row=0, column=0;
int cell = 0;
int YCells;
int cellWidth, cellHeight;
boolean beginRecord = false;
ArrayList<Character> charArray = new ArrayList();


//SETTINGS://///////////////////////////////////////////////////////
float scale = 1.5;                  // <- Scale factor for original image (should be greater than or equal to 1)
float brightness = 1.1;             // <- Brightness of output
int XCells = 50;                    // <- Number of horizontal cells
int textSize = 9;                   // <- Text Size
String imageName;        // <- Image file to load
String fileName;    // <- PDF File to save.
boolean random = false;              // <- Fill in random letters? Setting false will make all letters O

////////////////////////////////////////////////////////////////////


void setup(){
  //size(1000, 1184, PDF, "giraffe.pdf");
  size(displayWidth, displayHeight);
  selectInput("Select a file to Import", "getFile");
  while(imageName == null) delay(100);
  print(imageName);
  img = loadImage(imageName);
  
  fileName = showInputDialog("Enter output filename", "giraffe");
  if (fileName == null) exit();
  fileName += ".pdf";
  
  brightness = Float.parseFloat(showInputDialog("Brightness factor", "1.1"));
  scale = Float.parseFloat(showInputDialog("Scale size factor", "1.5"));
  XCells = Integer.parseInt(showInputDialog("XCells (Total horizontal cells)", "50"));
  textSize = Integer.parseInt(showInputDialog("Text font size", "9"));
  int reply = showConfirmDialog(null, "Generate random letters?", "", YES_NO_OPTION); 
  if (reply == YES_OPTION) random = true;
  
  YCells = img.height*XCells/img.width;
  cellWidth = (int) (img.width/XCells);
  cellHeight = (int) (img.height/YCells);
  
  background(0);
  textMode(SHAPE);
  textAlign(LEFT, TOP);
  textSize(textSize * scale);
  noStroke();
  
  for (int i=0; i< XCells * YCells; i++){
    if (random)
      charArray.add((char) random('A', 'Z'));
    else
      charArray.add('O');
  }
  //int p = 100, q = 100;
  //for (int i=0; i<p; i++){
  //  for (int j=0; j<q; j++){
  //    int colavg = 0;
  //    for (int a=0; a<width/p; a++){
  //      for (int b=0; b<height/q; b++){
  //        color c = img.get((int) ((i*width/p + a)/scale), (int) ((j*height/q + b)/scale)); //get grayscale
  //        colavg += 1.5 * (0.3 * red(c) + 0.59 * green(c) + 0.11 * blue(c));
  //      }
  //    }
  //    colavg /= ((width/p) * (height/q));
  //    if (colavg > 255) colavg = 255;
  //    noStroke();
  //    fill(colavg);
  //    while (!keyPressed){}
  //    //char c = (char) random(48, 94);
  //    char c = key;
  //    text(c, i*width/p, j*height/q);
  //  }
  //}
}

void draw(){
  background(0);
  for (int i=0; i<charArray.size(); i++){
    int iColumn = i % XCells;
    int iRow = (i - iColumn) / XCells;
    
    int colavg = 0;
    for (int x=0; x<cellWidth; x++){
      for (int y=0; y<cellHeight; y++){
        color c = img.get(iColumn*cellWidth + x, iRow*cellHeight + y);
        colavg += brightness * (0.3 * red(c) + 0.59 * green(c) + 0.11 * blue(c));
      }
    }
    colavg /= (cellWidth * cellHeight);
    if (colavg > 255) colavg = 255;
    
    fill(colavg);
    char c = charArray.get(i);
    if ((int) c != 0) text(c, iColumn*(cellWidth*scale), iRow*(cellHeight*scale));
  }
  if (beginRecord) {
    endRecord();
    beginRecord = false;
  }
  column = cell % XCells;
  row = (cell - column) / XCells;
  if (millis() % 1000 < 500){
    for (int x=0; x<cellWidth*scale; x++){
      for (int y=0; y<cellHeight*scale; y++){
        set((int) (column*cellWidth * scale + x), (int) (row*cellHeight * scale + y), color(255));
      }
    }
  }
}

void keyPressed(){
  if (key == BACKSPACE){
    /*for (int x=0; x<cellWidth; x++){
      for (int y=0; y<cellHeight; y++){
        set((column*cellWidth + x) * (int) scale, (row*cellHeight + y) * (int) scale, 0);
      }
    }*/
    charArray.set(cell, (char) 0);
  }else if (keyCode == LEFT){
    if (cell > 0) cell--;
  }else if (keyCode == RIGHT){
    if (cell < XCells * YCells - 1) cell++;
  }else if (keyCode == UP){
    if (cell >= XCells) cell -= XCells;
  }else if(keyCode ==DOWN){
    if (cell < XCells * (YCells - 1)) cell += XCells;
  }else if(key == RETURN || key == ENTER){
    PrintWriter txt = createWriter("characters.txt");
    for (int i=0; i<charArray.size(); i++){
      txt.println(charArray.get(i));
    }
    txt.flush();
    txt.close();
    
    beginRecord = true;
    beginRecord(PDF, fileName);
  }
  else if((key >=  'A' && key <= 'Z') || (key >= 'a' && key <= 'z')){
    column = cell % XCells;
    row = (cell - column) / XCells;
    
    int colavg = 0;
    for (int x=0; x<cellWidth; x++){
      for (int y=0; y<cellHeight; y++){
        color c = img.get(column*cellWidth + x, row*cellHeight + y);
        colavg += brightness * (0.3 * red(c) + 0.59 * green(c) + 0.11 * blue(c));
      }
    }
    colavg /= (cellWidth * cellHeight);
    if (colavg > 255) colavg = 255;
    noStroke();
    fill(colavg);
    //char c = (char) random(48, 94);
    char c = key;
    //text(c, column*(cellWidth*scale), row*(cellHeight*scale));
    charArray.set(cell, c);
    
    if (cell < XCells * YCells - 1) cell++;
  }
  println(cell);
}

void getFile(File file){
  if (file == null) exit();
  imageName = file.getAbsolutePath();
}