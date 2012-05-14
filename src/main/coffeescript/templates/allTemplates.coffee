@won ||= {}

@won.templates =
	
	menu : """
			<p>
			<a href="#workout" data-role="button" data-corners="true" data-shadow="true" data-iconshadow="true" data-wrapperels="span" data-theme="c" class="ui-btn ui-shadow ui-btn-corner-all ui-btn-up-c">
				<span class="ui-btn-inner ui-btn-corner-all">Workout</span>
			</a>
		</p>
		<p>
			<a href="#location/list" data-role="button" data-corners="true" data-shadow="true" data-iconshadow="true" data-wrapperels="span" data-theme="c" class="ui-btn ui-shadow ui-btn-corner-all ui-btn-up-c">
				<span class="ui-btn-inner ui-btn-corner-all">Locations</span>
			</a>
		</p>
		<p>
			<a href="#exercise/list" data-role="button" data-corners="true" data-shadow="true" data-iconshadow="true" data-wrapperels="span" data-theme="c" class="ui-btn ui-shadow ui-btn-corner-all ui-btn-up-c">
				<span class="ui-btn-inner ui-btn-corner-all">Exercises</span>
			</a>
		</p>
	"""
	
	exerciseList : """
		<h1>Exercises</h1>
		<ul data-role="listview" data-theme="g">
			<% _.each(excercises, function(excercise) { %> 
				<li><a href="#excercise/modify/<%=excercise.get("id")%>"><%=excercise.get("name")%></a></li>
			<% }); %>
		</ul>
		<a href="#main" data-role="button" data-inline="true">Back</a>
		<a href="#excercise/create" data-role="button" data-inline="true" data-theme="b">Create</a>
</ul>
	"""