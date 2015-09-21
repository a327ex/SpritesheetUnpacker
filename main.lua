yui = require 'yaoui'

function love.load()
    love.graphics.setBackgroundColor(24, 24, 24)

    images = {}
    width = 0
    height = 0

    yui.UI.registerEvents()

    main = yui.View(470, 0, 130, 400, {
        margin_top = 10,
        margin_left = 10,
        margin_bottom = 10,
        margin_right = 10,
        yui.Stack({
            margin_bottom = 10,
            spacing = 10,
            bottom = {
                yui.Flow({
                    spacing = 10,
                    yui.Textinput({w = 50, onTextChanged = function(self, text) width = tonumber(text) end}),
                    yui.Textinput({w = 50, onTextChanged = function(self, text) height = tonumber(text) end}),
                }),
                yui.Flow({
                    margin_right = 20,
                    right = {
                        yui.Button({text = 'Run!', onClick = function() doWork() end}),
                    }
                })
            }
        })
    })
end

function love.update(dt)
    yui.update({main})
    main:update(dt)
end

local heightSum = function(n)
    local sum = 0
    for i = 1, n do
        local h = images[i].image:getHeight()
        sum = sum + h
    end
    return sum
end

function love.draw()
    main:draw()

    for i, image in ipairs(images) do
        love.graphics.draw(image.image, 10, heightSum(i-1) + 10)
    end
end

function love.filedropped(file)
    if file:open('r') then
        local full_path = file:getFilename()
        local i, j = full_path:find('\\[^\\]*$')
        local path = full_path:sub(1, i)
        local filename = full_path:sub(i+1, -1)
        table.insert(images, {path = path, filename = filename, image = love.graphics.newImage(love.image.newImageData(love.filesystem.newFileData(file:read(), 'file')))})
    end
end

function getQuadAsImageData(image, x, y, w, h)
    local image_data = image:getData()
    local new_image_data = love.image.newImageData(w, h)
    for i = x, x+w-1 do
        for j = y, y+h-1 do
            local r, g, b, a = image_data:getPixel(i, j)
            new_image_data:setPixel(i-x, j-y, r, g, b, a)
        end
    end
    return new_image_data
end

function doWork()
    for _, img in ipairs(images) do
        local w, h = img.image:getWidth(), img.image:getHeight()
        local j = 0
        for i = 0, w-width, width do
            local quad_image_data = getQuadAsImageData(img.image, i, 0, width, height) 
            quad_image_data:encode('png', img.filename:sub(1, -5) .. '_' .. j .. '.png') 
            j = j + 1
        end
    end
end
