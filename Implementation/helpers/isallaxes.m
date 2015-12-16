function result = isallaxes(h)

result = all(all(ishghandle(h))) && ...
         length(findobj(h,'type','axes','-depth',0)) == length(h);

end