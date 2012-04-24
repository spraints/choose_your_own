require 'action_view'

module ChooseYourOwn
  module FormBuilder
    def choose_your_own method, &block
      builder = ChoiceBuilder.new(self, method)
      @template.content_tag :div, :class => "choose_your_own #{@object_name}_#{method}_choices" do
        choices_html = @template.capture(builder, &block)
        hidden_field(method) + builder.menu + choices_html
      end
    end

    class ChoiceBuilder
      def initialize form_builder, category_method
        @form_builder = form_builder
        @category_method = category_method
      end

      def choice(method, label = nil, &block)
        label ||= method.to_s.titleize
        choices << [method, label]
        block ||= lambda {}
        template.content_tag :div, :class => "#{selected?(method) ? 'active ' : ''}choice", :id => "#{object_name}_#{category_method}_#{method}", &block
      end

      def menu
        template.content_tag :ul, :class => 'menu' do
          choices.map do |method, label|
            tag = {}
            tag[:id] = "#{object_name}_menu_#{category_method}_#{method}" 
            tag[:class] = 'active' if selected?(method)
            template.content_tag :li, tag do
              label
            end
          end.join('').html_safe
        end
      end

      private

      def f               ; @form_builder                          ; end
      def template        ; f.instance_variable_get(:@template)    ; end
      def object_name     ; f.instance_variable_get(:@object_name) ; end
      def object          ; f.instance_variable_get(:@object)      ; end
      def category_method ; @category_method.to_s                  ; end
      def selected        ; @selected ||= ActionView::Helpers::InstanceTag.value_before_type_cast(object, category_method).to_s ; end

      def selected? method
        selected == method.to_s
      end

      def choices
        @choices ||= []
      end
    end
  end
end

ActionView::Helpers::FormBuilder.send :include, ChooseYourOwn::FormBuilder
