function [layout_out, data] = compile(layout)
    format shortG
    clear SFB_pat dSFB_pat bigram_disp bigram_1u bigram_2u SFB  bigrams left_pat right_pat right_count  key_usage;
    clear lateral_move lateral_SFB_pat  lateral_SFB_disp lateral_dSFB_disp lateral_dSFB_pat diag_1u_SFB_count diag_1u_dSFB_count lateral_bigram lateral_SFB;
    clear  SFB_2u_disp SFB_2u_pat dSFB_2u_pat SFB_2u dSFB_2u diag_1u_disp diag_1u_SFB_pat diag_1u_dSFB_pat diag_1u_SFB_count diag_SFB_percent diag_dSFB_percent lateral_SFB;
    clear  diag_2u_disp  diag_2u_SFB_pat diag_2u_dSFB_pat diag_2u_SFB_count diag_2u_dSFB_count left_hand_usage right_hand_usage;
    layout_size = size(layout);
    for i = 1:layout_size(2)
        str = layout(:,i);
        if (str == "")
            fprintf('Given layout has empty columns. \nReformatting.')
            layout(:,i) = [];
        end
        [~,B] = size(layout);
        if i == B
            break
        end
    end
    layout = rmmissing(layout,2,"MinNumMissing",2);
    layout_out = layout;

    % import text for analysis
    % 
    % specify file name here
    
    text = readlines("corpora.txt");
    % 
    % deleting empty lines and making lowercase
    
    TF1 = (text == ""); TF2 = (text=="?"); TF3 = (text=='"');
    text(TF1) = []; text(TF2) = "/"; text(TF3) = "'";
    text = replace(text,"?","/");
    text = replace(text,'"',"'");
    text = replace(text,":",";");
    text = lower(text);
    % 
    % Make text into one line
    
    text = join(text);
    text = join(text,1);
    % bigrams
    % *Same Finger Bigram (SFB)*: Pressing two keys with the same finger in conjunction. 
    % *Disjointed SFB (dSFB)*: Pressing two keys with the same finger, but separated 
    % by x letter or a space. *Same Finger Skipgram (SFS)*: Synonym for dSFB. *Lateral 
    % Stretch Bigram (LSB)*: A bigram where your hand must stretch laterally, as in 
    % using the middle finger following middle column usage on the same hand. An example 
    % is |*be*| on QWERTY.
    % 
    % assign bigrams. For the "qa" bigram for example your have to consider "qa", 
    % "q a", "aq", and "a q" 
    
    % this does not consider pionter finger movements 

    for i = 1:10
        SFB_pat(i*2-1) = (layout(1,i)+layout(2,i))|(layout(2,i)+layout(1,i));
        SFB_pat(i*2) = (layout(3,i)+layout(2,i))|(layout(2,i)+layout(3,i));
    end
    for i = 1:10
        dSFB_pat(i*2-1) = (layout(1,i)+lettersPattern(1)+layout(2,i))|(layout(1,i)+" "+layout(2,i))...
            |(layout(2,i)+lettersPattern(1)+layout(1,i))|(layout(2,i)+" "+layout(1,i));
        dSFB_pat(i*2) = (layout(3,i)+lettersPattern(1)+layout(2,i))|(layout(3,i)+" "+layout(2,i))...
            |(layout(2,i)+lettersPattern(1)+layout(3,i))|(layout(2,i)+" "+layout(3,i));
    end
    % 
    % record bigram types for displaying results
    
    for i = 1:10
        bigram_disp(i*2-1,1) = (layout(1,i)+layout(2,i));
        bigram_disp(i*2,1) = (layout(3,i)+layout(2,i));
    end
    % 
    % count bigram occurance
    
    [bigram_1u, bigram_2u] = deal(zeros(20,1));
    for i = 1:length(SFB_pat)
        bigram_1u(i,1) = count(text,SFB_pat(i));
        bigram_2u(i,1) = count(text,dSFB_pat(i));
    end
    SFB = bigram_1u; dSFB = bigram_2u;
    table(SFB,dSFB,'RowNames',bigram_disp)
    bigrams = sortrows(table(SFB,dSFB,'RowNames',bigram_disp),'SFB','descend')
    % find the usage for left and right hand
    % left:
    
    for i = 1:5
        left_pat(i*3-2,1) = layout(1,i);
        left_pat(i*3-1,1) = layout(2,i);
        left_pat(i*3,1) = layout(3,i);
    end
    
    for i = 1:length(left_pat)
        left_count(i,1) = count(text,left_pat(i));
    end
    table(left_pat,left_count)
    % 
    % right:
    for i = 1:5
        right_pat(i*3-2,1) = layout(1,i+5);
        right_pat(i*3-1,1) = layout(2,i+5);
        right_pat(i*3,1) = layout(3,i+5);
    end
    for i = 1:length(right_pat)
        right_count(i,1) = count(text,right_pat(i));
    end
    table(right_pat,right_count)
    letter = ((cat(1,left_pat,right_pat)));
    character_sum = sum(cat(1,left_count,right_count));
    percent = cat(1,left_count,right_count)/character_sum;
    key_usage = sortrows(table(letter,percent),'percent','descend');
    % 
    % LSB: lateral stretch bigrams, that would be the bigrams where the fingers 
    % stretch to the middle columns
    
    table(letter,percent)
    middle_letter = letter(13:18); middle_percent = percent(13:18); 
    lateral_move = table(middle_letter,middle_percent,'RowNames',middle_letter);
    for i = 1:3
        lateral_SFB_pat(i) = (layout(i,4)+layout(i,5))|(layout(i,5)+layout(i,4));
    end
    for i = 1:3
        lateral_SFB_pat(i+3) = (layout(i,6)+layout(2,7))|(layout(i,7)+layout(i,6));
    end
    for i = 1:3
        lateral_SFB_disp(i,1) = (layout(i,4)+layout(i,5));
        lateral_dSFB_disp(i,1) = (layout(i,4)+layout(i,5));
    end
    for i = 1:3
        lateral_SFB_disp(i+3,1) = (layout(i,6)+layout(i,7));
        lateral_dSFB_disp(i+3,1) = (layout(i,6)+layout(2,7));
    end
    for i = 1:3
        lateral_dSFB_pat(i) = (layout(i,4)+lettersPattern(1)+layout(i,5))|(layout(i,4)+" "+layout(i,5))...
            |(layout(i,5)+lettersPattern(1)+layout(i,4))|(layout(i,5)+" "+layout(i,4));
    end
    for i = 1:3
        lateral_dSFB_pat(i+3) = (layout(i,6)+lettersPattern(1)+layout(i,7))|(layout(i,6)+" "+layout(i,7))...
            |(layout(i,7)+lettersPattern(1)+layout(i,6))|(layout(i,7)+" "+layout(i,6));
    end
    for i = 1:length(lateral_SFB_pat)
        diag_1u_SFB_count(i,1) = count(text,lateral_SFB_pat(i));
    end
    for i = 1:length(lateral_dSFB_pat)
        diag_1u_dSFB_count(i,1) = count(text,lateral_dSFB_pat(i));
    end
    table(lateral_SFB_disp,diag_1u_SFB_count,lateral_dSFB_disp,diag_1u_dSFB_count)
    lateral_SFB_percent = diag_1u_SFB_count/(2*character_sum);
    lateral_dSFB_percent = diag_1u_dSFB_count/(2*character_sum);
    lateral_bigram = table(middle_letter,middle_percent,'RowNames',middle_letter);
    lateral_SFB = sortrows(table(lateral_SFB_disp,lateral_SFB_percent,lateral_dSFB_percent),'lateral_SFB_percent','descend');
    % 
    % 2u bigram
    
    for i = 1:10
        SFB_2u_disp(i,1) = layout(1,i)+layout(3,i);
        SFB_2u_pat(i,1) = layout(1,i)+layout(3,i)|layout(3,i)+layout(1,i);
        dSFB_2u_pat(i,1) = layout(1,i)+" "+layout(3,i)|layout(3,i)+lettersPattern(1)+layout(1,i)|layout(1,i)+lettersPattern(1)+layout(3,i)|layout(3,i)+" "+layout(1,i);
    end
    for i = 1:length(dSFB_2u_pat)
        SFB_2u(i,1) = count(text,dSFB_2u_pat(i));
        dSFB_2u(i,1) = count(text,dSFB_2u_pat(i));
    end
    table(SFB_2u_disp, SFB_2u,dSFB_2u)
    % 
    % diagonal 1u and 2u
    
    for i = 1:2
        diag_1u_disp(2*i-1,1) = layout(i,4)+layout(i+1,5);
        diag_1u_disp(2*i,1) = layout(i+1,4)+layout(i,5);
    end
    for i = 1:2
        diag_1u_disp(2*i-1+4,1) = layout(i,6)+layout(i+1,7);
        diag_1u_disp(2*i+4,1) = layout(i+1,6)+layout(i,7);
    end
    for i = 1:2
        diag_1u_SFB_pat(2*i-1,1) = layout(i,4)+layout(i+1,5)|layout(i+1,5)+layout(i,4);
        diag_1u_SFB_pat(2*i,1) = layout(i+1,4)+layout(i,5)|layout(i,5)+layout(i+1,4);
    end
    for i = 1:2
        diag_1u_SFB_pat(2*i-1+4,1) = layout(i,6)+layout(i+1,7)|layout(i+1,7)+layout(i,6);
        diag_1u_SFB_pat(2*i+4,1) = layout(i+1,6)+layout(i,7)|layout(i,7)+layout(i+1,6);
    end
    for i = 1:2
        diag_1u_dSFB_pat(2*i-1) = layout(i,4)+lettersPattern(1)+layout(i+1,5)|layout(i+1,5)+lettersPattern(1)+layout(i,4)|...
            layout(i,4)+" "+layout(i+1,5)|layout(i+1,5)+" "+layout(i,4);
    
        diag_1u_dSFB_pat(2*i) = layout(i+1,4)+lettersPattern(1)+layout(i,5)|layout(i,5)+lettersPattern(1)+layout(i+1,4)|...
            layout(i+1,4)+" "+layout(i,5)|layout(i,5)+" "+layout(i+1,4);
    end
    for i = 1:2
        diag_1u_dSFB_pat(2*i-1+4) = layout(i,6)+lettersPattern(1)+layout(i+1,7)|layout(i+1,7)+lettersPattern(1)+layout(i,6)|...
            layout(i,6)+" "+layout(i+1,7)|layout(i+1,6)+" "+layout(i,7);
        diag_1u_dSFB_pat(2*i+4) = layout(i+1,6)+lettersPattern(1)+layout(i,7)|layout(i,7)+lettersPattern(1)+layout(i+1,6)|...
            layout(i+1,6)+" "+layout(i,7)|layout(i,7)+" "+layout(i+1,6);
    end
    for i = 1:length(diag_1u_SFB_pat)
        diag_1u_SFB_count(i,1) = count(text,diag_1u_SFB_pat(i));
    end
    for i = 1:length(diag_1u_dSFB_pat)
        diag_1u_dSFB_count(i,1) = count(text,diag_1u_dSFB_pat(i));
    end
    table(diag_1u_disp,diag_1u_SFB_count,diag_1u_dSFB_count)
    diag_SFB_percent = diag_1u_SFB_count/(2*character_sum);
    diag_dSFB_percent = diag_1u_dSFB_count/(2*character_sum);
    lateral_SFB = sortrows(table(diag_1u_disp,diag_SFB_percent,diag_dSFB_percent),'diag_SFB_percent','descend');
    % 2u diagonal
    
    diag_2u_disp(1,1) = layout(1,4)+layout(3,5);
    diag_2u_disp(2,1) = layout(3,4)+layout(1,5);
    diag_2u_disp(3,1) = layout(1,6)+layout(3,7);
    diag_2u_disp(4,1) = layout(3,6)+layout(1,7);
    for i = 1:2
        diag_2u_SFB_pat(i,1) = layout(1,6-i)+layout(3,i+3)|layout(3,i+3)+layout(1,6-i);
    end
    
    for i = 1:2
        diag_2u_SFB_pat(i+2,1) = layout(1,8-i)+layout(3,i+5)|layout(3,i+5)+layout(1,8-i);
    end
    
    for i = 1:2
        diag_2u_dSFB_pat(i,1) = layout(1,6-i)+" "+layout(3,i+3)|layout(3,i+3)+lettersPattern(1)+layout(1,6-i)|layout(1,6-i)+lettersPattern(1)+layout(3,i+3)|layout(3,i+3)+" "+layout(1,6-i);
    end
    
    for i = 1:2
        diag_2u_dSFB_pat(i+2,1) = layout(1,8-i)+lettersPattern(1)+layout(3,i+5)|layout(3,i+5)+" "+layout(1,8-i)|layout(1,8-i)+" "+layout(3,i+5)|layout(3,i+5)+lettersPattern(1)+layout(1,8-i);
    end
    for i = 1:length(diag_2u_SFB_pat)
        diag_2u_SFB_count(i,1) = count(text,diag_2u_SFB_pat(i));
    end
    for i = 1:length(diag_2u_dSFB_pat)
        diag_2u_dSFB_count(i,1) = count(text,diag_2u_dSFB_pat(i));
    end
    table(diag_2u_disp,diag_2u_SFB_count,diag_2u_dSFB_count)
    % 
    % finding the character count usage
    
    a = reshape(left_count,[3,5]); b = reshape(right_count,[3,5]); c = cat(2,a,b);
    key_freq = c/sum(c,'all');
    % figure()
    % h = heatmap(key_freq);
    % 
    % Left and right hand usage
    
    left_hand_usage = sum(key_freq(:,1:5),'all');
    right_hand_usage = 1-left_hand_usage;
    % finger usage. 1 is left pinky and 8 is right pinky
    
    finger_freqs = sum(key_freq);
    % shared columns in the middle of the keyboard
    finger_4 = sum(finger_freqs(4:5));
    finger_5 = sum(finger_freqs(6:7));
    finger_8 = sum(finger_freqs(10:end));
    finger_freqs = cat(2,finger_freqs(1:3),finger_4,finger_5,finger_freqs(8:9),finger_8);
    format longG
    data = key_freq;
end
