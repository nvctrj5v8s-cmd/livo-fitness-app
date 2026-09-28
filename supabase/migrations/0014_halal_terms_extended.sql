-- LIVO halal rule, extended term lists (27 September 2026).
--
-- Replaces public.livo_halal_text_allowed from 0007/0009. All catalog
-- triggers and restrictive RLS policies call this function, so they pick up
-- the new terms automatically. Repeatable: create or replace only.
--
-- Keep in sync with lib/core/data/halal_content_policy.dart and
-- supabase/functions/barcode-lookup/index.ts (a Flutter test checks that
-- every term of the Dart lists also appears here).
--
-- Matching, identical to the app:
-- 1. lower case, ä/ö/ü/ß -> ae/oe/ue/ss, everything else except a-z0-9 -> space
-- 2. harmless phrases are removed ("blood orange", "goat cheese", ...)
-- 3. whole words or phrases; "root[a-z0-9]*" = word starts with root,
--    "[a-z0-9]+root" = longer German compound ending with root
-- 4. hard terms always block; land-animal meat needs halal/zabiha/dhabiha

create or replace function public.livo_halal_text_allowed(p_value text)
returns boolean
language plpgsql
immutable
as $$
declare
  normalized text;
  previous text;
  harmless_pattern constant text :=
    ' (blood orange|blood oranges|hamburger bun|hamburger buns|' ||
    'hamburger roll|hamburger rolls|hot dog bun|hot dog buns|' ||
    'hot dog roll|hot dog rolls|quail egg|quail eggs|goose egg|' ||
    'goose eggs|duck egg|duck eggs|goat cheese|cheese goat|goat milk|' ||
    'goats milk|goat s milk|milk goat|cod liver|steak sauce|salmon steak|' ||
    'tuna steak|fish steak|swordfish steak|halibut steak|' ||
    'cauliflower steak|sweet tamale|tamale sweet|fruchtfleisch|' ||
    'kokosfleisch|butterschmalz|lebertran|lachssteak|thunfischsteak|' ||
    'fischsteak|blumenkohlsteak|tofusteak|sellerieschnitzel|' ||
    'tofuschnitzel|fruit cocktail|cocktail sauce|shrimp cocktail|' ||
    'prawn cocktail|juice cocktail|cocktail tomato|cocktail tomatoes|' ||
    'meatless) ';
  hard_forbidden_pattern constant text :=
    '(^| )(pork|pig|swine|boar|schwein[a-z0-9]*|schweine|wildschwein|' ||
    'bacon[a-z0-9]*|ham|prosciutto[a-z0-9]*|salami[a-z0-9]*|' ||
    'pepperoni[a-z0-9]*|lard|lardo|lardon[a-z0-9]*|speck|spam|scrapple|' ||
    'chitterling[a-z0-9]*|chitterlings|mortadella[a-z0-9]*|' ||
    'pancetta[a-z0-9]*|guanciale|capicola|liverwurst[a-z0-9]*|' ||
    'schinken[a-z0-9]*|[a-z0-9]+schinken|schmalz[a-z0-9]*|' ||
    '[a-z0-9]+schmalz|kassler|kasseler|eisbein|saumagen|leberkaese|' ||
    'blutwurst|black pudding|eggs benedict|egg benedict|blood|blut|gelatin[a-z0-9]*|gelatine|' ||
    'collagen|kollagen|aspic|aspik|suelze|gummy[a-z0-9]*|gummies|' ||
    'gummi[a-z0-9]*|fruchtgummi[a-z0-9]*|weingummi|marshmallow[a-z0-9]*|' ||
    'jellybean[a-z0-9]*|jelly bean|jelly beans|jelly candy|jelly candies|' ||
    'jello|jell o|panna cotta|alcohol[a-z0-9]*|alkohol[a-z0-9]*|' ||
    'ethanol[a-z0-9]*|beer(?!e)[a-z0-9]*|bier|radler|wine|wein|rotwein|' ||
    'weisswein|redwine|whitewine|gluehwein|weinbrand|sekt|' ||
    'prosecco[a-z0-9]*|champagne[a-z0-9]*|vermouth[a-z0-9]*|wermut|' ||
    'sherry|sake|cider|hard seltzer|mead|whisky[a-z0-9]*|' ||
    'whiskey[a-z0-9]*|bourbon[a-z0-9]*|scotch|vodka[a-z0-9]*|rum|rumtopf|' ||
    'rumkugel|rumkugeln|gin|brandy[a-z0-9]*|cognac[a-z0-9]*|armagnac|' ||
    'calvados|grappa|ouzo|raki|absinth|absinthe|pisco|mezcal|' ||
    'tequila[a-z0-9]*|kirschwasser|obstler|schnapps[a-z0-9]*|schnaps|' ||
    'liqueur[a-z0-9]*|liquor[a-z0-9]*|likoer|[a-z0-9]+likoer|' ||
    'amaretto[a-z0-9]*|kahlua|baileys|aperol|campari|daiquiri[a-z0-9]*|' ||
    'margarita[a-z0-9]*|martini[a-z0-9]*|mojito[a-z0-9]*|mimosa|' ||
    'manhattan|negroni|cosmopolitan|caipirinha|screwdriver|' ||
    'sangria[a-z0-9]*|eggnog[a-z0-9]*|punsch|bowle|bloody mary|' ||
    'long island|pina colada|irish coffee|white russian|black russian|' ||
    'mai tai|hot toddy|rum punch|mint julep|tom collins|cuba libre|' ||
    'cocktail)( |$)';
  land_animal_pattern constant text :=
    '(^| )(meat[a-z0-9]*|fleisch[a-z0-9]*|[a-z0-9]+fleisch|' ||
    'chicken[a-z0-9]*|huhn|haehnchen[a-z0-9]*|hen|poultry|' ||
    'turkey[a-z0-9]*|pute[a-z0-9]*|truthahn|beef[a-z0-9]*|rind[a-z0-9]*|' ||
    'veal[a-z0-9]*|kalb[a-z0-9]*|lamb[a-z0-9]*|lamm[a-z0-9]*|mutton|goat|' ||
    'ziege|duck[a-z0-9]*|ente[a-z0-9]*|goose|gans|gaense|quail|wachtel|' ||
    'pheasant|fasan|venison|deer|elk|moose|hirsch|reh|bison|ostrich|' ||
    'rabbit|hare|kaninchen[a-z0-9]*|frog|froschschenkel|wurst|' ||
    '[a-z0-9]+wurst|sausage[a-z0-9]*|bratwurst[a-z0-9]*|knockwurst|' ||
    'knackwurst|bologna|frankfurter[a-z0-9]*|frankfurters|franks|hot dog|' ||
    'hot dogs|hotdog[a-z0-9]*|chorizo[a-z0-9]*|kielbasa[a-z0-9]*|' ||
    'andouille|pastrami[a-z0-9]*|jerky|mett|steak|[a-z0-9]+steak|steaks|' ||
    'ribeye|sirloin|tenderloin|porterhouse|brisket|rib|ribs|' ||
    'sparerib[a-z0-9]*|oxtail|ochsenschwanz|tongue|tripe|kutteln|pansen|' ||
    'gizzard[a-z0-9]*|sweetbread[a-z0-9]*|giblet[a-z0-9]*|offal|' ||
    'innereien|liver[a-z0-9]*|livers|leber[a-z0-9]*|hamburger[a-z0-9]*|' ||
    'cheeseburger[a-z0-9]*|chiliburger|whopper|big mac|salisbury|' ||
    'sloppy joe|pot roast|meatball|meatloaf|frikadelle[a-z0-9]*|bulette|' ||
    'buletten|hackfleisch[a-z0-9]*|gehacktes|kotelett[a-z0-9]*|' ||
    '[a-z0-9]+kotelett|schnitzel[a-z0-9]*|[a-z0-9]+schnitzel|' ||
    'gulasch[a-z0-9]*|[a-z0-9]+gulasch|goulash[a-z0-9]*|bolognese|gyro|' ||
    'gyros|doener|doner|kebab|kebap|shawarma|schawarma|carne|carnitas|' ||
    'barbacoa|birria|pozole|menudo|tamale|tamales|reuben|club sandwich|' ||
    'italian sandwich|cuban sandwich|french dip|shepherd s pie|' ||
    'shepherds pie|wonton soup|soup wonton|wonton dumpling|pot sticker|' ||
    'pot stickers|barbecue sandwich|frito pie)( |$)';
  halal_marker_pattern constant text :=
    '(^| )(halal|zabiha|dhabiha)( |$)';
begin
  normalized := replace(replace(replace(replace(
    lower(coalesce(p_value, '')),
    'ä', 'ae'), 'ö', 'oe'), 'ü', 'ue'), 'ß', 'ss');
  normalized := ' ' || trim(regexp_replace(normalized, '[^a-z0-9]+', ' ', 'g')) || ' ';
  -- Adjacent harmless phrases share one space; repeat until nothing changes.
  loop
    previous := normalized;
    normalized := regexp_replace(normalized, harmless_pattern, ' ', 'g');
    exit when normalized = previous;
  end loop;
  normalized := trim(normalized);
  if normalized = '' then
    return true;
  end if;
  if normalized ~ hard_forbidden_pattern then
    return false;
  end if;
  if normalized ~ land_animal_pattern and normalized !~ halal_marker_pattern then
    return false;
  end if;
  return true;
end;
$$;
