%% Creating a url for an html file and opening it in the default browser.
function figure2browser(path)
    url = ['file:///', path];
    system(sprintf('open -a Google\\ Chrome %s'), url);
end
