from xml.sax.handler import ContentHandler

class DBLPHandler(ContentHandler):

    PUBLICATION_TYPE_FIELD_NAME = "category";
    ARTICLE_TAG_NAME = "article";
    BOOK_TAG_NAME = "book";
    INPROCEEDINGS_TAG_NAME = "inproceedings";
    INCOLLECTION_TAG_NAME = "incollection";

    isPublication = False
    currentField = ""
    fieldValues = {}
    fieldNames = [PUBLICATION_TYPE_FIELD_NAME,"key","mdate","publtype","reviewid","rating","title","booktitle","pages","year","address","journal", "volume", "number", "month", "school", "chapter"]
    relationFields = ["publisher", "author", "editor", "cite", "url", "note", "isbn", "crossref"]
    tagNames = [PUBLICATION_TYPE_FIELD_NAME, ARTICLE_TAG_NAME, BOOK_TAG_NAME, INPROCEEDINGS_TAG_NAME, INCOLLECTION_TAG_NAME]
    file_dict = {}
    pub_count = 0

    def __init__(self):
        for rf in self.relationFields:
            self.file_dict[rf] = open(rf+'.csv', 'a')
        self.file_dict['publication'] = open('publication.csv', 'a')


    def startElement(self, name, attrs):
        if self.isPublicationStartTag(name):
            self.isPublication = True
            self.fieldValues[self.PUBLICATION_TYPE_FIELD_NAME] = name
            for key in attrs.keys():
                self.fieldValues[key] = ((attrs[key]).strip()).replace('\n','').replace('"','')
        self.currentField = name

    def endElement(self, name):
        if self.isPublicationClosingTag(name):
            self.pub_count += 1
            if self.pub_count%10 == 0:
                print "pub_count"
                print self.pub_count
            self.isPublication = False
            self.flushValues()
        elif not self.isPublication:
            return
        else:
            pubKey = self.fieldValues['key']
            if name in self.relationFields:
                self.file_dict[name].write('{},{}\n'.format(pubKey.encode('utf-8'), ((self.fieldValues[name]).replace('"','').strip()).encode('utf-8')))
                self.fieldValues[name] = ""

    def characters(self, characters):
        if not self.isPublication:
            return
        currentEntry = self.fieldValues.get(self.currentField, "")
        currentEntry += characters
        self.fieldValues[self.currentField] = currentEntry.replace('\n','')


    def isPublicationStartTag(self, tagname):
        return tagname.lower() in self.tagNames

    def isPublicationClosingTag(self, tagname):
        if self.isPublicationStartTag(tagname) and (self.fieldValues[self.PUBLICATION_TYPE_FIELD_NAME]).lower() == tagname.lower():
            return True
        else:
            return False

    def flushValues(self):
        pub_file = self.file_dict['publication']
        count = 0
        for fieldName in self.fieldNames:
            if fieldName in self.fieldValues:
                value = (self.fieldValues[fieldName]).replace(',', '')
                pub_file.write(value.encode('utf-8'))
            if count < len(self.fieldNames) - 1:
                pub_file.write(',')
            count += 1
        pub_file.write('\n')
        self.fieldValues = {}

    def closeFiles(self):
        for f in self.file_dict:
            self.file_dict[f].close()
