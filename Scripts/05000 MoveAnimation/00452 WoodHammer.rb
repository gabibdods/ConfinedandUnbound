ya = Yuki::Animation
# Wood Hammer
animation_user = ya.wait(0.1)
animation_target = ya.create_sprite(:viewport, :sprite, Sprite, nil, [:load, 'WoodHammer', :animation], [:set_rect, 0, 0, 195, 136], [:zoom=, 1], [:set_origin, 130, 106])
main_t_anim = ya.resolved
animation_target.play_before(main_t_anim)
main_t_anim.play_before(ya.move_sprite_position(0, :sprite, :target, :target))
main_t_anim.play_before(ya.se_play('moves/WoodHammer'))
main_t_anim.play_before(ya.wait(0.1))
main_t_anim.play_before(ya.send_command_to(:sprite, :set_rect, 0, 0, 195, 136))
main_t_anim.play_before(ya.wait(0.1))
main_t_anim.play_before(ya.send_command_to(:sprite, :set_rect, 0, 136, 195, 136))
main_t_anim.play_before(ya.wait(0.1))
main_t_anim.play_before(ya.send_command_to(:sprite, :set_rect, 0, 272, 195, 136))
main_t_anim.play_before(ya.wait(0.1))
main_t_anim.play_before(ya.send_command_to(:sprite, :set_rect, 0, 408, 195, 136))
main_t_anim.play_before(ya.wait(0.1))
animation_target.play_before(ya.dispose_sprite(:sprite))

Battle::MoveAnimation.register_specific_animation(:wood_hammer, :first_use, animation_user, animation_target)
