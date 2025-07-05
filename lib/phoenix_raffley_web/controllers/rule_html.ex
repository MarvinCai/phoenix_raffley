defmodule PhoenixRaffleyWeb.RuleHTML do
  use PhoenixRaffleyWeb, :html

  embed_templates "rule_html/*"

  def show(assigns) do
    ~H"""
    <h1><%= @greeting %></h1>
    <div class="rules">
      <p>
        <%= @rule.text %>
        </p>
    </div>
    """
  end
end
