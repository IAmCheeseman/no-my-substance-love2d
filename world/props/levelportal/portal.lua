
Objects.create_type("LevelPortal", {
    sprite = Sprite.new("world/props/levelportal/portal.png", 1, 0),
    vortex_upper = Sprite.new("world/props/levelportal/vortex.png", 1, 0),
    vortex_lower = Sprite.new("world/props/levelportal/vortex.png", 1, 0),
    depth = -1,

    on_create = function(self)
        self.player = Objects.grab("Player")

        self.vortex_upper.offset_x = self.vortex_upper.texture:getWidth() / 2
        self.vortex_upper.offset_y = self.vortex_upper.texture:getHeight() / 2
        self.vortex_lower.offset_x = self.vortex_lower.texture:getWidth() / 2
        self.vortex_lower.offset_y = self.vortex_lower.texture:getHeight() / 2

        self.vortex_lower.rotation = math.pi / 4
    end,
    on_update = function(self, dt)
        if Vector.distance_between(self.player.x, self.player.y, self.x, self.y) < 8 then
            current_level = current_level + 1
            Room.change_to("Level_" .. tostring(current_level))
        end

        self.vortex_upper.rotation = self.vortex_upper.rotation + dt * 3
        self.vortex_lower.rotation = self.vortex_lower.rotation + dt * 3.5
    end,
    on_draw = function(self)
        self.sprite:draw(self.x, self.y)

        love.graphics.setBlendMode("add")
        love.graphics.setColor(0, 0, 1)
        self.vortex_lower:draw(self.x + 8, self.y + 6)
        love.graphics.setColor(0, 1, 1)
        self.vortex_upper:draw(self.x + 8, self.y + 6)
        love.graphics.setBlendMode("alpha")
    end
})