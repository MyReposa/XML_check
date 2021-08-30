<?xml version='1.0' encoding='WINDOWS-1252'?>
<xsl:stylesheet version="1.0" 
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:ait="http://www.authorit.com/xml/authorit">
<xsl:output method="html" />

<!-- Load variable  -->
<xsl:variable name="IsTranslationJob">
    <xsl:choose>
    <xsl:when test="/ait:AuthorIT/ait:Information/ait:TranslationJob">true</xsl:when>
    <xsl:otherwise>false</xsl:otherwise>
    </xsl:choose>
</xsl:variable>

<xsl:template match="/ait:AuthorIT">
<HTML>
  <HEAD>
    <TITLE>
      AuthorIT XML
      [<xsl:value-of select="ait:Information/ait:Description" />]
    </TITLE> 
    <STYLE TYPE="text/css">
      A.fref:link    		{color:orange; text-decoration:none; font-style:italic}
      A.fref:visited 		{color:orange; text-decoration:none; font-style:italic}
      A.href:link    		{color:blue}
      A.href:visited 		{color:blue}
      A.tref:link   		{color:red; text-decoration:none; font-style:italic}
      A.tref:visited 		{color:red; text-decoration:none; font-style:italic}
      A.mref:link   		{color:lime}
      A.mref:visited 		{color:lime}
      .smalltext     		{font-family:verdana,tahoma; font-size:10px;}
      .mediumtext    		{font-family:arial; font-size:12px;}
      .propertyinherited  	{color:blue; font-style:italic}
      .property			    {font-style:italic}
      .sortorder     		{font-family:verdana,tahoma; font-size:10px; }
    </STYLE>
  </HEAD>
  <BODY>
    <!-- Display message if browser is not compatible -->
    <xsl:if test="dummy">
      <xsl:fallback>
          <B>The browser you are using is not able to display XML using XSLT stylesheets.<BR />
          Please use a later browser (e.g. Internet Explorer 6.0 or greater).</B>
          <BR /><BR /><BR /><BR /><BR /><BR /><BR /><BR /><BR /><BR />
          <BR /><BR /><BR /><BR /><BR /><BR /><BR /><BR /><BR /><BR />
      </xsl:fallback>
    </xsl:if>

    <!-- Display information -->
    <xsl:apply-templates select="ait:Information" />

    <!-- Display List Of Objects table -->
    <TABLE class="smalltext" border="1" bordercolor="#DCDCDC" style="border-collapse:collapse">
      <TR align="center">
        <TH colspan="4"><BIG>List of Objects</BIG></TH>
      </TR>
      <TR align="left">
        <TH width="10%">ObjectID</TH>
        <TH width="10%">Type</TH>
        <xsl:if test="$IsTranslationJob='true'">
          <TH width="10%">Word Count&#160;</TH>
        </xsl:if>
        <TH width="80%">Description</TH>
      </TR>

      <xsl:for-each select="ait:Objects/*">
        <TR>
           <TD><A href="#{ait:Object/ait:ID}" class="href"><xsl:value-of select="ait:Object/ait:ID"/></A></TD>
           <TD><xsl:value-of select="name()"/></TD>
           <xsl:if test="$IsTranslationJob='true'">
             <TD><xsl:value-of select="@wordcount"/></TD>
           </xsl:if>
           <TD><xsl:value-of select="ait:Object/ait:Description"/></TD>
        </TR>
      </xsl:for-each>      
    </TABLE>

    <!-- Display each object's details -->
    <xsl:for-each select="ait:Objects/ait:*">
      <xsl:call-template name="displayObjectContents"/>
    </xsl:for-each>
    <P/>
  </BODY>
</HTML>
</xsl:template>

<xsl:template match="ait:Information">
  <H2>
    <xsl:value-of select="ait:Description"/>
  </H2>
  <TABLE width="100%" class="mediumtext">
    <TR><TD></TD><TD>
      <TABLE width="100%" class="mediumtext">   
        <TR><TD class="property">Created by</TD><TD>'<xsl:value-of select="ait:Library/ait:User"/>'</TD></TR>
        <TR><TD class="property">Date</TD><TD><xsl:value-of select="ait:Date"/></TD></TR>
        <xsl:if test="ait:TranslationJob">
          <TR><TD colspan="2"><B>Translation Job</B></TD></TR>
          <xsl:for-each select="ait:TranslationJob/*">
            <xsl:choose>
              <xsl:when test="count(./*)=0">
                <!-- Dont display property if empty -->
                <xsl:if test=".!='' and name()!='GUID'">
                  <xsl:call-template name="addPropertyRow"/>
                </xsl:if>
              </xsl:when>
              <xsl:otherwise>
                <xsl:call-template name="addMultiPropertyRow"/>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:for-each>
        </xsl:if>
        <TR><TD class="property">Total Objects</TD><TD><xsl:value-of select="count(/ait:AuthorIT/ait:Objects/*)"/></TD></TR>         
        <TR><TD colspan="2"><B>Library</B></TD></TR>
        <TR><TD class="property">Name</TD><TD><xsl:value-of select="ait:Library/ait:Name"/></TD></TR>
        <TR><TD class="property">Locale</TD><TD><xsl:value-of select="ait:Library/ait:Locale/ait:Description"/></TD></TR>
      </TABLE>
    </TD></TR>
  </TABLE> 
</xsl:template>

<!-- Element Functions -->
<xsl:template name="displayObjectContents">
  <HR/>
  <A name="{ait:Object/ait:ID}" />
  <TABLE width="100%" class="mediumtext">   
    <TR><TD width="20%"></TD><TD width="80%"></TD></TR>
    <TD colspan="2" align="left"><xsl:call-template name="objectHeading"/></TD>
    <xsl:for-each select="ait:*">
      <xsl:choose>
        <xsl:when test="name()='Text' and name(..)='Topic'">
          <xsl:call-template name="addTopicText"/>
        </xsl:when>
        <xsl:when test="name()='ContentsNodes' and name(..)='Book'">
          <xsl:call-template name="displayTreeNodes"/>
        </xsl:when>
        <xsl:when test="name()='IndexNodes' and name(..)='Index'">
          <xsl:call-template name="displayTreeNodes"/>
        </xsl:when>
        <xsl:when test="name()='EmbeddedPicture' and name(..)='File'">
        </xsl:when>
        <xsl:when test="count(./*)=0">
          <!-- Dont display property if empty -->
          <xsl:if test=".!=''">  
            <xsl:call-template name="addPropertyRow"/>
          </xsl:if> 
        </xsl:when>
        <xsl:otherwise>   
          <xsl:call-template name="addMultiPropertyRow"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:for-each>	
  </TABLE>
</xsl:template>

<xsl:template name="objectHeading">
  <B>
    <BIG>
      <xsl:value-of select="name(.)"/>
      - <xsl:value-of select="ait:Object/ait:Description"/>
      (<xsl:value-of select="ait:Object/ait:ID"/>)
    </BIG>
  </B>
</xsl:template>

<xsl:template name="addTopicText">
  <TR>
    <TD valign="top" class="property">
      <xsl:value-of select="name()"/>
    </TD>
    <TD>
      <xsl:apply-templates/>
    </TD>
  </TR>
</xsl:template>

<xsl:template name="displayTreeNodes">
  <TR>
    <TD valign="top" class="property">
      <xsl:value-of select="name()"/>
    </TD>
    <TD>
      <TABLE class="mediumtext">
        <xsl:for-each select="ait:Node">
          <xsl:call-template name="addNode">
            <xsl:with-param name="indent"></xsl:with-param>
          </xsl:call-template>
        </xsl:for-each>
      </TABLE>
    </TD>
  </TR>
</xsl:template>

<xsl:template name="addNode">
  <xsl:param name="indent"/>
  <TR>
    <TD>
      <xsl:value-of select="$indent"/>
      <xsl:choose>
        <xsl:when test="@id=//ait:Object/ait:ID">
          <A href="#{@id}" class="href"><xsl:value-of select="@id"/></A>&#160;&#160;&#160;
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="@id"/>&#160;&#160;&#160;
        </xsl:otherwise>
      </xsl:choose>
    </TD>
    <TD>
      <xsl:call-template name="getObjectType"/>&#160;&#160;&#160;
    </TD>
    <TD valign="top">
      <xsl:call-template name="getDescription"/>
    </TD>
  </TR>
  <xsl:if test="ait:ChildNodes">
    <xsl:for-each select="ait:ChildNodes/ait:Node">    
      <xsl:call-template name="addNode">
        <xsl:with-param name="indent" select="concat($indent,'&#160;&#160;&#160;&#160;&#160;')"/>
      </xsl:call-template>
    </xsl:for-each>
  </xsl:if>
</xsl:template>

<xsl:template name="addPropertyRow">
  <TR>
    <TD valign="top">
      <xsl:choose>
        <xsl:when test="@inherited='true'">
          <xsl:attribute name="class">propertyinherited</xsl:attribute>
          <xsl:attribute name="title">This property is inherited.</xsl:attribute>
        </xsl:when>
        <xsl:otherwise>
          <xsl:attribute name="class">property</xsl:attribute>
        </xsl:otherwise>
      </xsl:choose>
      <xsl:value-of select="name()"/>&#160;&#160;&#160;
    </TD>
    <TD>
      <xsl:value-of select="."/>
        <xsl:variable name="SortOrder" select="@sortorder"/>
        <xsl:if test="$SortOrder!=''">
          <xsl:if test="$IsTranslationJob='true'">
            <span class="sortorder" title="Sort Order"> [:<xsl:value-of select="@sortorder"/>]</span>
          </xsl:if>
        </xsl:if>
    </TD>
  </TR>
</xsl:template>

<xsl:template name="addMultiPropertyRow">
  <TR>
    <TD valign="top">
      <xsl:choose>
        <xsl:when test="@inherited='true'">
          <xsl:attribute name="class">propertyinherited</xsl:attribute>
          <xsl:attribute name="title">This property is inherited.</xsl:attribute>
        </xsl:when>
        <xsl:otherwise>
          <xsl:attribute name="class">property</xsl:attribute>
        </xsl:otherwise>
      </xsl:choose>
      <xsl:value-of select="name()"/>&#160;&#160;&#160;
    </TD>
    <TD>
      <TABLE class="mediumtext" cellspacing="0" cellpadding="0">
        <xsl:choose>
          <xsl:when test="count(ait:*/ait:*)!=0">
            <xsl:for-each select="ait:*">
              <xsl:call-template name="addMultiPropertyRow"/>
            </xsl:for-each>
          </xsl:when>
          <xsl:otherwise>     
            <xsl:for-each select="ait:*">
              <xsl:call-template name="addPropertyRow"/>
            </xsl:for-each>
          </xsl:otherwise>
        </xsl:choose>
      </TABLE>
    </TD>
  </TR>
</xsl:template>

<!--Topic Text Elements -->
<xsl:template match="ait:p">
  <P><xsl:apply-templates/></P>
</xsl:template>

<xsl:template match="ait:href">
  <xsl:variable name="DisplayText">
    <xsl:call-template name="getPopupDescription" />
  </xsl:variable>

  <A href="#{@id}" 
     class="href"
     title="{$DisplayText}"
     onmouseover="status='{$DisplayText}'; return true"
     onmouseout="status=''">
       <xsl:value-of select="."/>
  </A>
</xsl:template>

<xsl:template match="ait:fref">
  <xsl:variable name="DisplayText">
    <xsl:call-template name="getPopupDescription" />
  </xsl:variable>

  <A href="#{@id}" 
     class="fref"
     title="{$DisplayText}"
     onmouseover="status='{$DisplayText}'; return true"
     onmouseout="status=''">
       (File Object)
  </A>
</xsl:template>

<xsl:template match="ait:mref">
  <xsl:variable name="DisplayText">
    <xsl:call-template name="getPopupDescription" />
  </xsl:variable>

  <A href="#{@id}"
     class="mref"
     title="{$DisplayText}"
     onmouseover="status='{$DisplayText}'; return true"
     onmouseout="status=''">
       <xsl:value-of select="."/>
  </A>
</xsl:template>

<xsl:template match="ait:tref">
  <xsl:variable name="DisplayText">
    <xsl:call-template name="getPopupDescription" />
  </xsl:variable>
  <A href="#{@id}" 
     class="tref"
     title="Click to locate Topic"
     onmouseover="status='Click to locate Topic'; return true"
     onmouseout="status=''">
       [<xsl:value-of select="$DisplayText"/>]
  </A>
</xsl:template>

<xsl:template match="ait:cs">
  <xsl:variable name="DisplayText">
    <xsl:call-template name="getPopupDescription" />
  </xsl:variable>
  <B title="{$DisplayText}"><xsl:value-of select="."/></B>
</xsl:template>

<xsl:template match="ait:br"><BR /></xsl:template>
<xsl:template match="ait:nbd">-</xsl:template>
<!-- <xsl:template match="ait:nbs"><xsl:text> </xsl:text></xsl:template> -->
<xsl:template match="ait:nbs">&#160;</xsl:template>


<xsl:template match="ait:table">
  <TABLE border="1" class="mediumtext"><xsl:apply-templates select="ait:tr"/></TABLE>
</xsl:template>

<xsl:template match="ait:tr">
  <TR><xsl:apply-templates select="ait:td"/></TR>
</xsl:template>

<xsl:template match="ait:td">
  <TD valign="top">
    <xsl:if test="@ait:rowspan>1">
      <xsl:attribute name="rowspan"><xsl:value-of select="@ait:rowspan"/></xsl:attribute>
    </xsl:if>
    <xsl:if test="@colspan>1">
      <xsl:attribute name="colspan"><xsl:value-of select="@ait:colspan"/></xsl:attribute>
    </xsl:if>
    <xsl:apply-templates select="ait:p"/>
  </TD>
</xsl:template>

<!-- Functions -->
<xsl:template name="getPopupDescription">
  <xsl:variable name="ObjectID" select="@id"/>
  <xsl:variable name="ObjectDescription"> 
    <xsl:choose>
      <xsl:when test="$ObjectID = //ait:Object/ait:ID">"<xsl:value-of select="//ait:Object[ait:ID = $ObjectID]/ait:Description"/>"</xsl:when>
      <xsl:when test="$ObjectID = //ait:ObjectSummary/ait:ID">"<xsl:value-of select="//ait:ObjectSummary[ait:ID = $ObjectID]/ait:Description"/>"</xsl:when>
      <xsl:otherwise>(unknown)</xsl:otherwise>
    </xsl:choose>
  </xsl:variable>
  <xsl:variable name="ObjectType">
    <xsl:choose>
      <xsl:when test="name() = 'fref'">File</xsl:when>
      <xsl:when test="name() = 'href'">Hyperlink</xsl:when>
      <xsl:when test="name() = 'mref'">Macro</xsl:when>
      <xsl:when test="name() = 'tref'">Topic</xsl:when>
      <xsl:when test="name() = 'cs'">Style</xsl:when>
    </xsl:choose>
  </xsl:variable> 
  <B><xsl:value-of select="$ObjectType"/> Object: <xsl:value-of select="$ObjectDescription"/> (<xsl:value-of select="$ObjectID"/>)</B>
</xsl:template>

<xsl:template name="getDescription">
  <xsl:variable name="ObjectID" select="@id"/>
  <xsl:variable name="ObjectDescription"> 
    <xsl:choose>
      <xsl:when test="$ObjectID = //ait:Object/ait:ID"><xsl:value-of select="//ait:Object[ait:ID = $ObjectID]/ait:Description"/></xsl:when>
      <xsl:when test="$ObjectID = //ait:ObjectSummary/ait:ID"><xsl:value-of select="//ait:ObjectSummary[ait:ID = $ObjectID]/ait:Description"/></xsl:when>
      <xsl:otherwise>(unknown)</xsl:otherwise>
    </xsl:choose>
  </xsl:variable>
  <xsl:value-of select="$ObjectDescription"/>
</xsl:template>

<xsl:template name="getObjectType">
  <xsl:variable name="ObjectID" select="@id"/>
  <xsl:variable name="ObjectType"> 
    <xsl:choose>
      <xsl:when test="$ObjectID = //ait:Object/ait:ID"><xsl:value-of select="//ait:Object[ait:ID = $ObjectID]/ait:Type"/></xsl:when>
      <xsl:when test="$ObjectID = //ait:ObjectSummary/ait:ID"><xsl:value-of select="//ait:ObjectSummary[ait:ID = $ObjectID]/ait:Type"/></xsl:when>
    </xsl:choose>
  </xsl:variable>
  <xsl:value-of select="$ObjectType"/>
</xsl:template>

<!--
<xsl:template name="upperCase">
  <xsl:param name="inputString"/>
  <xsl:value-of select="concat(translate(substring($inputString, 1, 1), 
    'abcdefghijklmnopqrstuvwxyz', 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'), substring($inputString, 2))"/> 
</xsl:template>

<xsl:call-template name="upperCase">
  <xsl:with-param name="inputString" select="name(..)"/>
</xsl:call-template>
-->

</xsl:stylesheet>

