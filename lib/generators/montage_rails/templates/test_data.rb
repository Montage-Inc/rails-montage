<% 10.times do |i| -%>
-
  id: <%= SecureRandom.uuid %>
<% attributes.each do |attribute| -%>
  <%= attribute.name -%>: <%= random_for_type(attribute.type) %>
<% end -%>
<% end %>
