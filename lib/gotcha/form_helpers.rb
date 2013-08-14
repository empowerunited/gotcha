module Gotcha

  module FormHelpers

    # Propose a gotcha to the user - question and answer hash
    def gotcha(options = {})
      options[:label_options] ||= {class:"gotcha required control-label"}
      form = options[:form] or raise "please pass the form object"
      options[:text_field_options] ||= {}
      if gotcha = Gotcha.random
        field = "gotcha_response[#{gotcha.class.name.to_s}-#{Digest::MD5.hexdigest(gotcha.class.down_transform(gotcha.answer))}]"

        simple_form = []
        simple_form << form.label(field, gotcha.question, options[:label_options])

        simple_form << content_tag(:span, class: "bubble", :data => {'original-title' => options[:tooltip]}) do
          content_tag(:i, '', class: "icon-question-sign")
        end if options[:tooltip]

        simple_form << content_tag(:div, class: 'controls') do
          concat text_field_tag(field, nil, options[:text_field_options])
          concat content_tag(:span, gotcha_error, class: "help-inline")
        end

        simple_form << form.hint('No special characters, please!') if options[:hint]
        simple_form << form.error(:username, id: 'user_name_error') if gotcha_error

        content_tag :div, class: "control-group string required gotcha captcha #{ @_gotcha_validated === false ? 'error' : ''}" do
          simple_form.join('').html_safe
        end
      else
        raise "No Gotchas Installed"
      end
    end

    # Return the gotcha error if its needed
    def gotcha_error
      t('gotcha.error_message', :default => 'Failed to validate the Gotcha.') if @_gotcha_validated === false
    end

  end


  # gotcha with bootstrap3 markup
  def bootstap3_gotcha(options = {})
    options[:label_options] ||= {}
    options[:text_field_options] ||= {}

    horizontal = options[:horizontal] ||= false

    if gotcha = Gotcha.random
      field = "gotcha_response[#{gotcha.class.name.to_s}-#{Digest::MD5.hexdigest(gotcha.class.down_transform(gotcha.answer))}]"
      content_tag :div, class: "form-group #{@_gotcha_validated === false ? 'has-error' : ''}" do
        tooltip = build_tooltip options[:tooltip]
        content = label_tag(field, gotcha.question, options[:label_options].merge(class: "#{horizontal ? 'control-label col-lg-4' : ''}"))
        content = "#{content}#{tooltip}"

        input = text_field_tag(field, nil, options[:text_field_options].merge(class: 'form-control gotcha captcha'))
        error = build_error options[:error_message]

        content = content + content_tag(:div, input + error, class: "#{horizontal ? 'col-lg-8' : ''}")
        content.html_safe
      end
    else
      raise "No Gotchas Installed"
    end
  end

  private
  def build_tooltip tooltip_content
    if tooltip_content
      content_tag(:span, :class => 'bubble', :"data-original-title" => tooltip_content) do
        content_tag(:span, '', :class => 'glyphicon glyphicon-question-sign')
      end
    end
  end

  def build_error error_message
    if @_gotcha_validated === false
      content_tag(:span, class: 'help-block') do
        error_message
      end
    end
  end

end
