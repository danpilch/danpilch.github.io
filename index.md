---
layout: default
title: Posts
---

## Personal Posts

<ul class="posts">
  {% for post in site.categories.personal %}
    <li class="post">
      <a href="{{ post.url }}">{{ post.title }}</a><br />
      <time class="publish-date" datetime="{{ post.date | date: '%f' }}">
        {{ post.date | date: "%b %-d, %Y" }}
      </time>
    </li>
  {% endfor %}
</ul>

## Community Posts

<ul class="posts">
  {% for post in site.categories.community %}
    <li class="post">
      <a href="{{ post.url }}">{{ post.title }}</a><br />
      <time class="publish-date" datetime="{{ post.date | date: '%f' }}">
        {{ post.date | date: "%b %-d, %Y" }}
      </time>
    </li>
  {% endfor %}
</ul>
