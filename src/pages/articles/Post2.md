---
public: true
layout: ../../layouts/BlogPost.astro

title: "UI/UX Tidbit: ActivityIndicator on paginated content"
description: A simple way of improving usability on React Native apps

createdAt: 1673700536
updatedAt: 1673700536
---

Whenever we're making an HTTP request, it's useful to give the user some feedback of what's happening - especially
in the very beginning of the app's lifecycle, where we probably have no cached data and the UI might look "broken".
The [ActivityIndicator](https://reactnative.dev/docs/activityindicator) serves that purpose very well: you can
overlay the screen with a translucent grey, the `ActivityIndicator`, and it will be self-evident that something is 
happening.

Using it in excess, however, can be to the detriment of the application and the user experience. It can give you the
impression that too much is happening, and that it's interrupting your flow.

That becomes very clear for paginated content, when the user wants to scroll to a new page without being pestered by
the UI.

There are many possible solutions for this sort of scenario, such as loading a bunch of pages initially,
always preloading a certain number of adjacent pages from the current index, caching all responses and
from time to time reload the cache, etc. One thing they all have in common is that they require some structural
code and more business logic to manage.

A quick-fix for such situation might be to only communicate to the user that some loading is happening if it
takes *too long*, up to a point where it's clearly perceivable and looks like something broke. At that point,
it makes sense to comfort the user that everything is still working, it's just taking longer than usual.

With hooks, that becomes quite easy to do: when a `fetch` request is triggered, start a `setTimeout` that
changes the status of the `ActivityMonitor` visibility *only when* the time threshold is reached.

```js
// Controls the ActivityMonitor
const [isLoading, setIsLoading] = useState(false);

useEffect(() => {
  // If the HTTP call takes longer than 1.5s, set isLoading to true
  // Note: setTimeout returns the ID of this timer, which we can use to cancel it prior to the callback being invoked
  const timeoutId = setTimeout(() => setIsLoading(true), 1500);
  
  // The HTTP request
  const fetched = doSomeExpensiveRequest();
  // Once the fetched Promise is fulfilled, we do two things:
  // 1. clear (cancel) the timeout for setting the ActivityMonitor - does nothing if the timeout already completed
  // 2. set isLoading to false - which also does nothing if it was already not-visible
  fetched.finally(() => {
    clearTimeout(timeoutId);
    setIsLoading(false);
  });
  
  // more logic code goes here to use the result of doSomeExpensiveRequest...
}, [doSomeExpensiveRequest, setIsLoading]);
```

With that, you can rest assured that your code won't bother the user too much, without the need to immediately look into
caching systems and what not.
