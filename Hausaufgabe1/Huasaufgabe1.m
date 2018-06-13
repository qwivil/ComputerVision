img = imread('/Users/ybpang/Pictures/WechatIMG23090.jpeg');
gray = rgb_to_gray(img);
merkmale = harris_detektor_upgrade(gray, 'segment_length', 9, 'k', 0.06, 'do_plot', true);
