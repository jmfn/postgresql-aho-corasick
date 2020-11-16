CREATE OR REPLACE FUNCTION substring_intersect (substrings text, search_strings text, separator char(1) default chr(31))
  RETURNS TABLE (substr text, search_strings text[])
AS $$
import ahocorasick

def substring_intersect(substrings, search_strings, separator):
  if not substrings or len(substrings) == 0:
    return {}

  if not search_strings or len(search_strings) == 0:
    return {}

  # prep search
  substrings = substrings.split(separator)
  search_strings_length = len(search_strings)

  # build trie from substrings to search for
  A = ahocorasick.Automaton()

  for index, str in enumerate(substrings, start=0):
    A.add_word(str, index)

  A.make_automaton()

  # results keyed on substring, value is a dict of search_strings
  results = {}

  # search
  for search_strings_index, substring_index in A.iter(search_strings):
    # extract the item around the search_strings_index
    left_index = search_strings.rfind(separator, 0, search_strings_index)
    left_index = left_index + 1 if left_index > -1 else 0
    right_index = search_strings.find(separator, search_strings_index) or search_strings_length
    right_index = right_index if right_index > -1 else search_strings_length

    substring = substrings[substring_index]
    search_string = search_strings[left_index:right_index]

    # add the found substring and its search_string to results
    if not substring in results:
      results[substring] = {search_string}
    elif search_string not in results[substring]:
      results[substring].add(search_string)

  # complete
  return results

# do search
results = substring_intersect(substrings, search_strings, separator)

# map dict into list of tuples
return [(k, list(v)) for k, v in results.items()]

$$ LANGUAGE plpython3u;

/*
SELECT * from substring_intersect('a,ball,ca,i', 'ask,can,i,have,coffee', ',');

substr	search_strings
ca	{"can"}
i	  {"i"}
a	  {"have","can","ask"}
*/