$(document).ready(function() {

  // preload the spinner image
  var spinner = $('<img/>').attr('src', '/images/spinner.gif').attr('alt', 'Chwila, moment...').attr('class', 'loading')

  // attach file upload form to the <body> element if there is a file upload button on the page
  if ($('button[type="button"].file_upload_button').size() > 0) {
    var button = $('button[type="button"].file_upload_button')
    var button_offset = button.offset()

    // data-* attributes
    var title = button.attr('data-title')
    var action = button.attr('data-action')
    var directory = button.attr('data-directory')
    var filename = button.attr('data-filename')
    var callback = button.attr('data-callback')

    // create the file upload form
    var form = $('<form class="file_upload_form" action="' + action + '" target="iframe" method="post" enctype="multipart/form-data"></form>')
    var div = $('<div class="file_upload_box"></div>')

    if (AUTH_TOKEN != undefined) {
      div.append($('<input type="hidden" name="authenticity_token" value="' + AUTH_TOKEN + '" />'))
    }

    if (title != undefined) {
      var h2_title = $('<h2>' + title + '</h2>')
      div.append(h2_title)
    }

    if (directory != undefined) {
      var hidden_directory = $('<input type="hidden" name="directory" value="' + directory + '" />')
      div.append(hidden_directory)
    }

    if (filename != undefined) {
      var hidden_filename = $('<input type="hidden" name="filename" value="' + filename + '" />')
      div.append(hidden_filename)
    }

    if (callback != undefined) {
      var hidden_callback = $('<input type="hidden" name="callback" value="' + callback + '" />')
      div.append(hidden_callback)
    }

    // file browser
    div.append('<input type="file" name="file" size="30" />')

    // overwrite existing file?
    div.append($('<p class="confirmation"><input type="checkbox" name="overwrite" id="file_upload_overwrite" /> <label for="file_upload_overwrite">zastąp istniejący plik</label>'))

    // upload / cancel buttons + iframe
    div.append($('<p class="buttons"><input type="button" value="Wgraj" class="upload" /><input type="button" value="Zamknij" class="cancel" /><iframe id="iframe" name="iframe"></iframe></p>'))

    // message
    div.append($('<p class="message"></p>'))

    // attach form to the body tag
    form.append(div)
    $('body').prepend(form)

    // apply css positioning (give the box a "block: display" style for a split second to correctly read its "offsets")
    div.css('display', 'block')
    div.css('left', button_offset.left + button[0].offsetWidth - div[0].offsetWidth)
    div.css('top', button_offset.top + button[0].offsetHeight + 2)
    div.css('display', 'none')
  }

  // show/hide file upload form
  $('button[type="button"].file_upload_button, .file_upload_form .cancel').click(function() {
    $('.file_upload_box').slideToggle(100)
  })

  // upload file (form submit)
  $('.file_upload_form .upload').click(function() {
    // remove any previously attached spinners
    $(this).parent().find('.loading').remove()

    // clear previous messages
    $(this).parent().parent().find('.message').text('').attr('class', 'message')

    // add spinner
    $(this).parent().append(spinner.clone())

    // submit form
    $(this).parent().parent().parent().submit()
  })

})
