window.ChooseYourOwn =
  choice_from_menu : (menu) -> $('#' + $(menu).attr('id').replace('menu_for_',''))

jQuery ->
  $ = jQuery
  $('body').delegate '.choose_your_own > .menu > .menu_item', 'click', ->
    $this = $(this)
    $this.closest('.menu').children().removeClass('active')
    $this.addClass('active')
    top = $this.closest('.choose_your_own')
    top.children('input').val($this.data('value'))
    top.children().removeClass('active')
    ChooseYourOwn.choice_from_menu(this).addClass('active')
