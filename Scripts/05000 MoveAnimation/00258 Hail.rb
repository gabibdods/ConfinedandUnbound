ya = Yuki::Animation
animation_target = Yuki::Animation::UserBankRelativeAnimation.new
# Hail
animation_user = ya.wait(0.1)
animation_target.play_on_bank(1, ya.create_sprite(:viewport, :sprite, Sprite, nil, [:load, 'Hail', :animation], [:set_rect, 0, 0, 540, 191], [:zoom=, 1], [:set_origin, 360, 120]))
animation_target.play_on_bank(0, ya.create_sprite(:viewport, :sprite, Sprite, nil, [:load, 'Hail', :animation], [:set_rect, 0, 0, 540, 191], [:zoom=, 1], [:set_origin, 240, 190]))
main_t_anim = ya.resolved
animation_target.play_before(main_t_anim)
main_t_anim.play_before(ya.move_sprite_position(0, :sprite, :target, :target))
main_t_anim.play_before(ya.se_play('moves/Hail'))
main_t_anim.play_before(ya.wait(0.01))
main_t_anim.play_before(ya.send_command_to(:sprite, :set_rect, 0, 0, 540, 191))
main_t_anim.play_before(ya.wait(0.25))
main_t_anim.play_before(ya.send_command_to(:sprite, :set_rect, 540, 0, 540, 191))
main_t_anim.play_before(ya.wait(0.25))
main_t_anim.play_before(ya.send_command_to(:sprite, :set_rect, 0, 0, 540, 191))
main_t_anim.play_before(ya.wait(0.25))
main_t_anim.play_before(ya.send_command_to(:sprite, :set_rect, 540, 0, 540, 191))
main_t_anim.play_before(ya.wait(0.25))
main_t_anim.play_before(ya.send_command_to(:sprite, :set_rect, 0, 0, 540, 191))
main_t_anim.play_before(ya.wait(0.25))
main_t_anim.play_before(ya.send_command_to(:sprite, :set_rect, 540, 0, 540, 191))
main_t_anim.play_before(ya.wait(0.25))
main_t_anim.play_before(ya.send_command_to(:sprite, :set_rect, 0, 0, 540, 191))
main_t_anim.play_before(ya.wait(0.25))
animation_target.play_before(ya.dispose_sprite(:sprite))

Battle::MoveAnimation.register_specific_animation(:hail, :first_use, animation_user, animation_target)
