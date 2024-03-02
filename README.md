TODO:
- build frontend
- move processing to cloud service
- integrate Japanese segmentation
- inegrate context-aware grammar parsing e.g. prevent mistranslation of 的，者 etc to semantic definitions when inappropriate. 

## Hard-translator

Half-silly, half serious project.  
  
This program receives a sentence input and translates it into one or more target languages. It then translates each individual word in the translated sentence back to the original user input' language and prints that out:

```
天今天天氣很好

The weather is good today
(這)(天氣)(是)(好)(今天)
```

```
Are you working today?

你今天在工作吗？
(you)(Today)(at)(Job)(?)(？)
```

My English-learning friends sometimes struggle to adopt English grammar patterns. Particularly Chinese is "close but different", and so this is a little tool just to help friends see basic differences.  
  
More elaborate inputs produce less refined results.