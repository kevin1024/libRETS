/*
 * Copyright (C) 2005 National Association of REALTORS(R)
 * Portions Copyright (C) 2014 Real Estate Standards Organziation
 *
 * All rights reserved.
 *
 * Permission is hereby granted, free of charge, to any person
 * obtaining a copy of this software and associated documentation
 * files (the "Software"), to deal in the Software without
 * restriction, including without limitation the rights to use, copy,
 * modify, merge, publish, distribute, and/or sell copies of the
 * Software, and to permit persons to whom the Software is furnished
 * to do so, provided that the above copyright notice(s) and this
 * permission notice appear in all copies of the Software and that
 * both the above copyright notice(s) and this permission notice
 * appear in supporting documentation.
 */
#include "librets/SearchRequest.h"

using namespace librets;
using std::string;

const char * SearchRequest::FORMAT_PARAMETER = "Format";
const char * SearchRequest::STANDARD_NAMES_PARAMETER = "StandardNames";
const char * SearchRequest::QUERY_TYPE_PARAMETER = "QueryType";
const char * SearchRequest::SEARCH_TYPE_PARAMETER = "SearchType";
const char * SearchRequest::CLASS_PARAMETER = "Class";
const char * SearchRequest::QUERY_PARAMETER = "Query";
const char * SearchRequest::SELECT_PARAMETER = "Select";
const char * SearchRequest::COUNT_PARAMETER = "Count";
const char * SearchRequest::LIMIT_PARAMETER = "Limit";
const char * SearchRequest::OFFSET_PARAMETER = "Offset";
const char * SearchRequest::RESTRICTED_PARAMETER = "RestrictedIndicator";
const char * SearchRequest::PAYLOAD_PARAMETER = "Payload";

SearchRequest::SearchRequest(string searchType, string searchClass,
                             string query)
{
    SetStandardNames(false);
    SetQueryType(DMQL2);
    SetQueryParameter(SEARCH_TYPE_PARAMETER, searchType);
    SetQueryParameter(CLASS_PARAMETER, searchClass);
    SetQueryParameter(QUERY_PARAMETER, query);
    SetCountType(RECORD_COUNT_AND_RESULTS);
    SetLimit(LIMIT_DEFAULT);
    SetOffset(OFFSET_NONE);
}

void SearchRequest::SetLimit(int limit)
{
    if (limit == LIMIT_DEFAULT)
    {
        SetQueryParameter(LIMIT_PARAMETER, "");
    }
    else if (limit == LIMIT_NONE)
    {
        SetQueryParameter(LIMIT_PARAMETER, "NONE");
    }
    else
    {
        SetQueryParameter(LIMIT_PARAMETER, limit);
    }
}

void SearchRequest::SetOffset(int offset)
{
    if (offset == OFFSET_NONE)
    {
        SetQueryParameter(OFFSET_PARAMETER, "");
    }
    else
    {
        SetQueryParameter(OFFSET_PARAMETER, offset);
    }
}

void SearchRequest::SetSelect(string select)
{
    SetQueryParameter(SELECT_PARAMETER, select);
}

void SearchRequest::SetCountType(CountType countType)
{
    switch (countType)
    {
        case RECORD_COUNT_AND_RESULTS:
            SetQueryParameter(COUNT_PARAMETER, "1");
            break;

        case RECORD_COUNT_ONLY:
            SetQueryParameter(COUNT_PARAMETER, "2");
            break;

        case NO_RECORD_COUNT:
        default:
            SetQueryParameter(COUNT_PARAMETER, "0");
    }
}

void SearchRequest::SetStandardNames(bool standardNames)
{
    SetQueryParameter(STANDARD_NAMES_PARAMETER, standardNames ? "1" : "0");
}

void SearchRequest::SetQueryType(QueryType queryType)
{
    switch (queryType)
    {
        case DMQL:
            SetQueryParameter(QUERY_TYPE_PARAMETER, "DMQL");
            break;
            
        case DMQL2:
            SetQueryParameter(QUERY_TYPE_PARAMETER, "DMQL2");
            break;
    }
}

void SearchRequest::SetFormatType(FormatType formatType)
{
    switch (formatType)
    {
        case COMPACT:
            SetQueryParameter(FORMAT_PARAMETER, "COMPACT");
            break;

        case COMPACT_DECODED:
            SetQueryParameter(FORMAT_PARAMETER, "COMPACT-DECODED");
            break;
    }
}

void SearchRequest::SetRestrictedIndicator(std::string restrictedIndicator)
{
    SetQueryParameter(RESTRICTED_PARAMETER, restrictedIndicator);
}

void SearchRequest::SetPayload(std::string payload)
{
    SetQueryParameter(PAYLOAD_PARAMETER, payload);
}
